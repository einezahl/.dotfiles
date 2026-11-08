#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["numpy", "tifffile", "imagecodecs", "imageio"]
# ///
"""Print a quick overview of an image directory or a single image.

Usage: image_info.py PATH

For a directory: image counts per format, subdirectories, shape/dtype counts
from the headers, and pixel statistics from up to 50 evenly spaced images,
grouped into intensity images and masks: per-channel statistics, pooled
histograms, darkest/brightest image, and the label values of the masks.

For an image: shape, dtype, bit depth, intensity statistics, a text histogram
with a fixed number of bins over the full bit-depth range (RGB channels side by
side in their color), and the unique values (color tuples for RGB) with their
pixel counts if there are at most 10, e.g. for segmentation masks.
"""

import os
import sys
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from pathlib import Path

import imageio.v3 as iio
import numpy as np
import tifffile

TIFF_SUFFIXES = {".tif", ".tiff"}
IMAGE_SUFFIXES = TIFF_SUFFIXES | {".png", ".jpg", ".jpeg", ".bmp", ".gif", ".webp"}
UNIQUE_MAX_LISTED = 10
HISTOGRAM_BINS = 32
HISTOGRAM_BIN_COLUMNS_SINGLE = 2
HISTOGRAM_BIN_COLUMNS_SIDE_BY_SIDE = 1
HISTOGRAM_HEIGHT = 12
BLOCKS = " ▁▂▃▄▅▆▇█"
CHANNEL_NAMES = ["red", "green", "blue", "alpha"]
CHANNEL_COLORS = ["\033[91m", "\033[92m", "\033[94m", ""]
RESET = "\033[0m"
DIRECTORY_MAX_LISTED = 50
DIRECTORY_MAX_LOADED = 50
# Images decoded concurrently for the directory overview. Decoding and the
# numpy passes release the GIL, so threads help; the cap bounds memory, since
# every worker holds one full image.
DIRECTORY_LOAD_THREADS = min(4, os.cpu_count() or 1)
SAMPLE_PIXELS_PER_IMAGE = 100_000
# Largest value range for which pixels are counted per value (np.bincount, one
# pass) instead of sorted (np.unique, np.percentile, np.histogram). 2^24 counts
# is 128 MiB; 8 and 16 bit images always qualify.
COUNTS_MAX_VALUES = 2**24

# Pixel counts per value for one channel (index == value), or None when the
# channel's values do not fit a small non-negative integer range.
Counts = np.ndarray | None


def is_image(path: Path) -> bool:
    """Return True if the file extension is one of the supported image formats."""
    return path.suffix.lower() in IMAGE_SUFFIXES


def load_image(path: Path) -> np.ndarray:
    """Load an image as an array, with tifffile for TIFFs and imageio otherwise."""
    if path.suffix.lower() in TIFF_SUFFIXES:
        return tifffile.imread(path)
    return iio.imread(path)


def read_header(path: Path) -> tuple[tuple[int, ...], np.dtype]:
    """Return an image's shape and dtype from its header, without loading pixels."""
    if path.suffix.lower() in TIFF_SUFFIXES:
        with tifffile.TiffFile(path) as tif:
            series = tif.series[0]
            return series.shape, series.dtype
    props = iio.improps(path)
    return props.shape, props.dtype


def format_bytes(size: int) -> str:
    """Format a byte count with a binary unit, e.g. 1536 -> '1.5 KiB'."""
    value = float(size)
    for unit in ["B", "KiB", "MiB", "GiB"]:
        if value < 1024 or unit == "GiB":
            return f"{value:.1f} {unit}" if unit != "B" else f"{int(value)} B"
        value /= 1024
    raise AssertionError("unreachable")


def format_number(value: float) -> str:
    """Format a pixel value: integers without decimals, floats with 4 significant digits."""
    if float(value).is_integer():
        return str(int(value))
    return f"{value:.4g}"


def value_counts(channel: np.ndarray) -> Counts:
    """Count the pixels of each value in one pass, or return None for other data.

    Works for integer channels whose values lie in 0..COUNTS_MAX_VALUES-1 (8 and
    16 bit images always do). The result has one entry per value, so
    `counts[v]` is the number of pixels with value `v`. Everything the script
    reports about a channel (unique values, statistics, percentiles, histogram,
    clipping) is derived from these counts; the sort-based numpy functions are
    only the fallback for floats and other wide ranges and take 100x longer on
    large images.
    """
    if not np.issubdtype(channel.dtype, np.integer) or channel.size == 0:
        return None
    if np.issubdtype(channel.dtype, np.unsignedinteger) and channel.dtype.itemsize <= 2:
        return np.bincount(channel.ravel(), minlength=int(np.iinfo(channel.dtype).max) + 1)
    low = int(channel.min())
    high = int(channel.max())
    if low < 0 or high >= COUNTS_MAX_VALUES:
        return None
    return np.bincount(channel.ravel(), minlength=high + 1)


def counts_range(counts: np.ndarray) -> tuple[int, int]:
    """Return the smallest and largest value with a non-zero count."""
    present = np.flatnonzero(counts)
    return int(present[0]), int(present[-1])


def counts_mean_std(counts: np.ndarray) -> tuple[float, float]:
    """Return mean and population standard deviation (like ndarray.std) from counts."""
    values = np.arange(len(counts), dtype=np.float64)
    total = counts.sum()
    mean = float(np.dot(counts, values) / total)
    variance = float(np.dot(counts, (values - mean) ** 2) / total)
    return mean, float(np.sqrt(variance))


def counts_percentiles(counts: np.ndarray, percentiles: list[float]) -> list[float]:
    """Return percentiles from counts, interpolating like np.percentile's default.

    np.percentile (method 'linear') places percentile q at sorted position
    q / 100 * (n - 1) and interpolates between the two neighbouring pixels. The
    pixel at sorted position k is the smallest value whose cumulative count
    exceeds k.
    """
    cumulative = np.cumsum(counts)
    total = int(cumulative[-1])

    def value_at(position: int) -> float:
        return float(np.searchsorted(cumulative, position, side="right"))

    results = []
    for q in percentiles:
        position = q / 100 * (total - 1)
        lower = int(np.floor(position))
        upper = int(np.ceil(position))
        fraction = position - lower
        results.append(value_at(lower) + (value_at(upper) - value_at(lower)) * fraction)
    return results


def counts_histogram(counts: np.ndarray, bins: int, low: float, high: float) -> np.ndarray:
    """Bin the counts like np.histogram(values, bins, range=(low, high)) would."""
    values = np.arange(len(counts), dtype=np.float64)
    inside = (values >= low) & (values <= high)
    index = np.floor((values[inside] - low) / (high - low) * bins).astype(int)
    index = np.minimum(index, bins - 1)
    return np.bincount(index, weights=counts[inside], minlength=bins)


def describe_bit_depth(img: np.ndarray) -> str:
    """Describe the storage bit depth and, for integers, how many bits the values use.

    A 12-bit SEM image stored as uint16 shows as '16 bit (values use 12 bit)'.
    """
    storage_bits = img.dtype.itemsize * 8
    if not np.issubdtype(img.dtype, np.integer) or img.size == 0:
        return f"{storage_bits} bit"
    used_bits = max(int(img.max()).bit_length(), 1)
    return f"{storage_bits} bit (values use {used_bits} bit)"


def print_statistics(img: np.ndarray, counts: Counts) -> None:
    """Print min/max/mean/std, percentiles and, for integers, the clipped fraction.

    `counts` are the image's value counts (see value_counts) or None, in which
    case the values are computed from the pixels directly.
    """
    percentiles = [0.1, 1, 50, 99, 99.9]
    if counts is not None:
        low, high = counts_range(counts)
        mean, std = counts_mean_std(counts)
        values = counts_percentiles(counts, percentiles)
    else:
        data = img.astype(np.float64)
        low, high = data.min(), data.max()
        mean, std = data.mean(), data.std()
        values = np.percentile(data, percentiles)
    print(f"min / max      {format_number(low)} / {format_number(high)}")
    print(f"mean / std     {mean:.4g} / {std:.4g}")
    line = "  ".join(f"p{p:g}={format_number(v)}" for p, v in zip(percentiles, values))
    print(f"percentiles    {line}")

    if np.issubdtype(img.dtype, np.integer):
        info = np.iinfo(img.dtype)
        if counts is not None:
            # counts only exist for non-negative values, so a negative info.min
            # has no pixels; info.max may lie beyond the counted range
            at_min = int(counts[0]) if info.min == 0 else 0
            at_max = int(counts[info.max]) if info.max < len(counts) else 0
        else:
            at_min = np.count_nonzero(img == info.min)
            at_max = np.count_nonzero(img == info.max)
        at_min /= img.size
        at_max /= img.size
        print(f"clipped        {at_min:.2%} at {info.min}, {at_max:.2%} at {info.max}")


def channel_range(channel: np.ndarray, counts: Counts) -> tuple[float, float]:
    """Return a channel's min and max, from the counts when available."""
    if counts is not None:
        return counts_range(counts)
    return float(channel.min()), float(channel.max())


def histogram_range(
    dtype: np.dtype, low: float, high: float
) -> tuple[float, float, str, str, str]:
    """Return the histogram range, the labels for its two limits, and a depth label.

    `low` and `high` are the smallest and largest value over all channels.
    Non-negative integer images span the full range of their bit depth, so the
    bins are comparable between images: 0..2^n-1 with n the bits the values use
    (at least 8). A 12-bit SEM image stored as uint16 spans 0..4095. Other
    images (floats, signed integers) span their min..max.
    """
    if np.issubdtype(dtype, np.integer) and low >= 0:
        bits = max(int(high).bit_length(), 8)
        return 0, 2**bits, "0", str(2**bits - 1), f"{bits} bit"
    if high == low:
        high = low + 1
    return low, high, format_number(low), format_number(high), "min..max"


def histogram_panel(
    fractions: np.ndarray,
    peak: float,
    title: str,
    low_label: str,
    high_label: str,
    bin_columns: int,
) -> list[str]:
    """Render one histogram with bins along the x-axis as equal-width text lines.

    `fractions` is the share of pixels per bin and `peak` the share that fills
    the full height, so several panels can share one y-scale. Each bin is
    `bin_columns` characters wide.
    """
    plot_width = len(fractions) * bin_columns
    axis_pad = " " * 7
    lines = [f"{axis_pad} {title}"]
    heights = fractions / peak * HISTOGRAM_HEIGHT
    for row in reversed(range(HISTOGRAM_HEIGHT)):
        if row == HISTOGRAM_HEIGHT - 1:
            prefix = f"{peak:6.1%} ┤"
        else:
            prefix = f"{axis_pad}│"
        bars = ""
        for height in heights:
            fill = min(max(height - row, 0.0), 1.0)
            bars += BLOCKS[round(fill * 8)] * bin_columns
        lines.append(prefix + bars)
    lines.append(f"{axis_pad}└" + "─" * plot_width)
    gap = plot_width - len(low_label) - len(high_label)
    lines.append(f"{axis_pad} {low_label}{' ' * max(gap, 1)}{high_label}")
    width = len(axis_pad) + 1 + plot_width
    return [line.ljust(width) for line in lines]


def print_histograms(
    channels: list[np.ndarray], counts: list[Counts], names: list[str], colors: list[str]
) -> None:
    """Print one histogram per channel side by side, in the channel's color.

    All channels share the bin range (from the whole image) and the y-scale.
    Side-by-side panels use narrower bins so three of them fit in one row.
    `counts` holds each channel's value counts (see value_counts) or None.
    """
    ranges = [channel_range(channel, c) for channel, c in zip(channels, counts)]
    low, high, low_label, high_label, depth = histogram_range(
        channels[0].dtype, min(r[0] for r in ranges), max(r[1] for r in ranges)
    )
    fractions = []
    for channel, channel_counts in zip(channels, counts):
        if channel_counts is not None:
            histogram = counts_histogram(channel_counts, HISTOGRAM_BINS, low, high)
        else:
            histogram, _ = np.histogram(channel, bins=HISTOGRAM_BINS, range=(low, high))
        fractions.append(histogram / channel.size)
    peak = max(float(f.max()) for f in fractions)
    if len(channels) == 1:
        bin_columns = HISTOGRAM_BIN_COLUMNS_SINGLE
    else:
        bin_columns = HISTOGRAM_BIN_COLUMNS_SIDE_BY_SIDE

    panels = []
    for channel_fractions, name, color in zip(fractions, names, colors):
        title = f"{name} ({depth})"
        panel = histogram_panel(
            channel_fractions, peak, title, low_label, high_label, bin_columns
        )
        panels.append([f"{color}{line}{RESET if color else ''}" for line in panel])

    print()
    for row in zip(*panels):
        print("   ".join(row))


def format_value(value: np.ndarray) -> str:
    """Format a unique value: a number for greyscale, a tuple for a color pixel."""
    if value.ndim == 0:
        return format_number(value)
    return "(" + ", ".join(format_number(v) for v in value) + ")"


def print_unique_values(values: np.ndarray, counts: np.ndarray, total: int) -> None:
    """Print each unique value with its pixel count, or a note if there are too many."""
    print()
    if len(values) > UNIQUE_MAX_LISTED:
        print(f"too many unique values to list ({len(values):,} > {UNIQUE_MAX_LISTED})")
        return
    print("unique values")
    labels = [format_value(value) for value in values]
    label_width = max(len(label) for label in labels)
    for label, count in zip(labels, counts):
        print(f"  {label:>{label_width}}  {count:>12,} px  {count / total:7.2%}")


def channel_labels(channel_count: int) -> tuple[list[str], list[str]]:
    """Return display names and ANSI colors for 1 (intensity) or 3/4 (RGB(A)) channels."""
    if channel_count == 1:
        return ["intensity"], [""]
    return CHANNEL_NAMES[:channel_count], CHANNEL_COLORS[:channel_count]


def split_channels(img: np.ndarray) -> tuple[list[np.ndarray], list[str], list[str]]:
    """Split an image into channels with display names and ANSI colors.

    RGB(A) images (last axis of length 3 or 4) give one array per color channel;
    everything else, including z-stacks, is a single intensity channel.
    """
    if img.ndim >= 3 and img.shape[-1] in (3, 4):
        channels = [img[..., index] for index in range(img.shape[-1])]
    else:
        channels = [img]
    names, colors = channel_labels(len(channels))
    return channels, names, colors


def colored(text: str, color: str) -> str:
    """Wrap text in an ANSI color code; an empty color leaves it unchanged."""
    if not color:
        return text
    return f"{color}{text}{RESET}"


def unique_values(
    img: np.ndarray, channels: list[np.ndarray], counts: list[Counts]
) -> tuple[np.ndarray, np.ndarray]:
    """Return the unique values and their pixel counts; color pixels count as tuples.

    Single channels come straight from their value counts. Unsigned color
    pixels are packed into one integer per pixel (red in the high bits) before
    np.unique, which sorts them ~100x faster than np.unique(axis=0) on rows
    and in the same lexicographic order. Everything else sorts the rows.
    """
    channel_count = len(channels)
    if channel_count == 1:
        if counts[0] is not None:
            values = np.flatnonzero(counts[0])
            return values.astype(img.dtype), counts[0][values]
        return np.unique(img, return_counts=True)

    bits = img.dtype.itemsize * 8
    if np.issubdtype(img.dtype, np.unsignedinteger) and bits * channel_count <= 64:
        packed_dtype = np.uint32 if bits * channel_count <= 32 else np.uint64
        packed = np.zeros(channels[0].size, dtype=packed_dtype)
        for index, channel in enumerate(channels):
            shift = bits * (channel_count - 1 - index)
            packed |= channel.ravel().astype(packed_dtype) << packed_dtype(shift)
        packed_values, packed_counts = np.unique(packed, return_counts=True)
        mask = packed_dtype(2**bits - 1)
        values = np.stack(
            [
                (packed_values >> packed_dtype(bits * (channel_count - 1 - index))) & mask
                for index in range(channel_count)
            ],
            axis=1,
        ).astype(img.dtype)
        return values, packed_counts
    return np.unique(img.reshape(-1, channel_count), axis=0, return_counts=True)


def describe_image(path: Path) -> None:
    """Print the full overview for one image file."""
    img = load_image(path)
    print(f"{path.name}  ({format_bytes(path.stat().st_size)})")
    print()
    print(f"shape          {img.shape}")
    print(f"dtype          {img.dtype}")
    print(f"bit depth      {describe_bit_depth(img)}")
    if img.size == 0:
        return

    channels, names, colors = split_channels(img)
    channel_counts = [value_counts(channel) for channel in channels]
    values, counts = unique_values(img, channels, channel_counts)
    pixel_count = channels[0].size
    if len(channels) == 1:
        print(f"unique values  {len(values):,}")
        print_statistics(img, channel_counts[0])
    else:
        print(f"unique colors  {len(values):,}")
        for channel, counts_of_channel, name, color in zip(
            channels, channel_counts, names, colors
        ):
            print()
            print(colored(name, color))
            print_statistics(channel, counts_of_channel)

    print_histograms(channels, channel_counts, names, colors)
    print_unique_values(values, counts, pixel_count)


@dataclass
class ImageSummary:
    """Per-image statistics collected for the directory overview."""

    path: Path
    dtype: np.dtype
    channel_count: int
    is_mask: bool
    mins: list[float]
    maxs: list[float]
    means: list[float]
    samples: list[np.ndarray]
    values: list[tuple[float, ...]]
    counts: list[int]
    pixel_count: int


def sample_pixels(channel: np.ndarray) -> np.ndarray:
    """Return an evenly strided subset of at most SAMPLE_PIXELS_PER_IMAGE pixels.

    Keeps memory bounded when pooling many large images for the directory
    histogram. Equivalent slower version: `channel.ravel()` (all pixels).
    """
    flat = channel.ravel()
    step = max(1, flat.size // SAMPLE_PIXELS_PER_IMAGE)
    return flat[::step]


def summarize_image(path: Path) -> ImageSummary:
    """Load an image and collect its per-channel statistics and unique values."""
    img = load_image(path)
    channels, _, _ = split_channels(img)
    channel_counts = [value_counts(channel) for channel in channels]
    values, counts = unique_values(img, channels, channel_counts)
    value_tuples = [tuple(np.atleast_1d(value).tolist()) for value in values]
    return ImageSummary(
        path=path,
        dtype=img.dtype,
        channel_count=len(channels),
        is_mask=len(values) <= UNIQUE_MAX_LISTED,
        mins=[float(channel.min()) for channel in channels],
        maxs=[float(channel.max()) for channel in channels],
        means=[float(channel.mean()) for channel in channels],
        samples=[sample_pixels(channel) for channel in channels],
        values=value_tuples,
        counts=[int(count) for count in counts],
        pixel_count=channels[0].size,
    )


def evenly_spaced(items: list[Path], count: int) -> list[Path]:
    """Pick up to `count` items spread evenly over the list, keeping their order."""
    if len(items) <= count:
        return items
    indices = np.linspace(0, len(items) - 1, count).round().astype(int)
    return [items[index] for index in indices]


def format_key(key: tuple[float, ...]) -> str:
    """Format a unique-value key: a plain number, or a tuple for color pixels."""
    if len(key) == 1:
        return format_number(key[0])
    return "(" + ", ".join(format_number(v) for v in key) + ")"


def print_channel_table(summaries: list[ImageSummary], names: list[str], colors: list[str]) -> None:
    """Print min/max over all images, pooled mean/std, and the spread of per-image means."""
    print(f"  {'channel':<10} {'min':>9} {'max':>9} {'mean':>9} {'std':>9}   per-image mean")
    for index, (name, color) in enumerate(zip(names, colors)):
        pooled = np.concatenate([s.samples[index] for s in summaries]).astype(np.float64)
        low = min(s.mins[index] for s in summaries)
        high = max(s.maxs[index] for s in summaries)
        means = [s.means[index] for s in summaries]
        row = (
            f"  {name:<10} {format_number(low):>9} {format_number(high):>9}"
            f" {pooled.mean():>9.4g} {pooled.std():>9.4g}"
            f"   {min(means):.4g} – {max(means):.4g}"
        )
        print(colored(row, color))


def print_brightness_extremes(summaries: list[ImageSummary]) -> None:
    """Print the darkest and brightest image by mean intensity over all channels."""
    if len(summaries) < 2:
        return
    by_mean = sorted(summaries, key=lambda s: float(np.mean(s.means)))
    darkest = by_mean[0]
    brightest = by_mean[-1]
    print(f"  darkest    {darkest.path.name}  (mean {np.mean(darkest.means):.4g})")
    print(f"  brightest  {brightest.path.name}  (mean {np.mean(brightest.means):.4g})")


def print_mask_labels(summaries: list[ImageSummary]) -> None:
    """Print each label value over all masks: images containing it and pixel share."""
    image_counts: Counter[tuple[float, ...]] = Counter()
    pixel_counts: Counter[tuple[float, ...]] = Counter()
    for summary in summaries:
        for value, count in zip(summary.values, summary.counts):
            image_counts[value] += 1
            pixel_counts[value] += count
    total = sum(summary.pixel_count for summary in summaries)

    if len(image_counts) > UNIQUE_MAX_LISTED:
        print(f"  too many label values to list ({len(image_counts):,} > {UNIQUE_MAX_LISTED})")
        return
    labels = {key: format_key(key) for key in image_counts}
    label_width = max(len("label"), *(len(label) for label in labels.values()))
    print(f"  {'label':>{label_width}}  {'in images':>9}  {'pixels':>7}")
    for key in sorted(image_counts):
        share = pixel_counts[key] / total
        print(f"  {labels[key]:>{label_width}}  {image_counts[key]:>9}  {share:7.2%}")


def print_group(summaries: list[ImageSummary]) -> None:
    """Print statistics for images of one kind, channel count and dtype.

    Intensity images get the channel table, darkest/brightest image and pooled
    histograms; masks get their label values only.
    """
    first = summaries[0]
    kind = "masks" if first.is_mask else "intensity images"
    channels = "1 channel" if first.channel_count == 1 else f"{first.channel_count} channels"
    print()
    print(f"── {kind} · {channels} · {first.dtype} · {len(summaries)} loaded ──")

    if first.is_mask:
        print_mask_labels(summaries)
        return
    names, colors = channel_labels(first.channel_count)
    print_channel_table(summaries, names, colors)
    print_brightness_extremes(summaries)

    pooled = [
        np.concatenate([s.samples[index] for s in summaries]).astype(first.dtype)
        for index in range(first.channel_count)
    ]
    print_histograms(pooled, [value_counts(channel) for channel in pooled], names, colors)


def count_directory(directory: Path) -> tuple[int, int]:
    """Return the number of files and of images directly inside a directory."""
    try:
        files = [entry for entry in directory.iterdir() if entry.is_file()]
    except OSError:
        return 0, 0
    return len(files), sum(1 for entry in files if is_image(entry))


Header = tuple[tuple[int, ...], np.dtype]


def print_header_overview(images: list[Path]) -> dict[Path, Header]:
    """Print shape/dtype counts and file-size range from headers; return them per image."""
    headers: dict[Path, Header] = {}
    unreadable: list[Path] = []
    for image in images:
        try:
            headers[image] = read_header(image)
        except Exception:
            unreadable.append(image)

    print()
    print("shape / dtype")
    layout_counts = Counter(f"{shape} {dtype}" for shape, dtype in headers.values())
    for layout, count in layout_counts.most_common():
        print(f"  {count:>6} × {layout}")
    sizes = [image.stat().st_size for image in images]
    print(f"file sizes   {format_bytes(min(sizes))} – {format_bytes(max(sizes))}"
          f"  (total {format_bytes(sum(sizes))})")
    if unreadable:
        names = ", ".join(image.name for image in unreadable[:5])
        print(f"unreadable   {len(unreadable)} ({names}{', ...' if len(unreadable) > 5 else ''})")
    return headers


def print_image_list(
    images: list[Path], headers: dict[Path, Header], summaries: dict[Path, ImageSummary]
) -> None:
    """Print the first images with shape, dtype and size, plus mean or label count if loaded."""
    print()
    print("images")
    shown = images[:DIRECTORY_MAX_LISTED]
    name_width = max(len(image.name) for image in shown)
    for image in shown:
        size = format_bytes(image.stat().st_size)
        if image in headers:
            shape, dtype = headers[image]
            layout = f"{str(shape):<18} {str(dtype):<8}"
        else:
            layout = f"{'(unreadable)':<27}"
        line = f"  {image.name:<{name_width}}  {layout} {size:>10}"
        summary = summaries.get(image)
        if summary is not None:
            if summary.is_mask:
                line += f"  mask       {len(summary.values)} labels"
            else:
                means = " / ".join(f"{mean:.4g}" for mean in summary.means)
                line += f"  intensity  mean {means}"
        print(line)
    if len(images) > DIRECTORY_MAX_LISTED:
        print(f"  ... and {len(images) - DIRECTORY_MAX_LISTED} more")


def describe_directory(directory: Path) -> None:
    """Print file and image counts, header overview, and pixel statistics per image group."""
    entries = sorted(directory.iterdir())
    files = [entry for entry in entries if entry.is_file()]
    subdirectories = [entry for entry in entries if entry.is_dir()]
    images = [entry for entry in files if is_image(entry)]
    total_size = sum(entry.stat().st_size for entry in files)

    print(f"{directory.resolve()}")
    print()
    print(f"{len(files)} files ({format_bytes(total_size)}), {len(subdirectories)} subdirectories")
    image_formats = Counter(image.suffix.lower() for image in images)
    formats = ", ".join(f"{count} {suffix}" for suffix, count in image_formats.most_common())
    print(f"{len(images)} images" + (f" ({formats})" if formats else ""))
    other_formats = Counter(entry.suffix.lower() or "without extension" for entry in files if not is_image(entry))
    if other_formats:
        others = ", ".join(f"{count} {suffix}" for suffix, count in other_formats.most_common())
        print(f"{len(files) - len(images)} other files ({others})")

    if subdirectories:
        print()
        print("subdirectories")
        name_width = max(len(subdirectory.name) for subdirectory in subdirectories)
        for subdirectory in subdirectories[:DIRECTORY_MAX_LISTED]:
            file_count, image_count = count_directory(subdirectory)
            print(f"  {subdirectory.name + '/':<{name_width + 1}}  {file_count:>6} files  {image_count:>6} images")
        if len(subdirectories) > DIRECTORY_MAX_LISTED:
            print(f"  ... and {len(subdirectories) - DIRECTORY_MAX_LISTED} more")

    if not images:
        return
    headers = print_header_overview(images)
    readable = [image for image in images if image in headers]

    loaded = evenly_spaced(readable, DIRECTORY_MAX_LOADED)
    summaries: dict[Path, ImageSummary] = {}
    with ThreadPoolExecutor(max_workers=DIRECTORY_LOAD_THREADS) as executor:
        futures = [executor.submit(summarize_image, image) for image in loaded]
        for image, future in zip(loaded, futures):
            try:
                summaries[image] = future.result()
            except Exception:
                print(f"failed to load {image.name}")

    print()
    sampled = "all" if len(loaded) == len(readable) else "evenly spaced"
    print(f"pixel statistics from {len(summaries)} of {len(images)} images ({sampled})")
    masks = sum(1 for summary in summaries.values() if summary.is_mask)
    print(f"  {len(summaries) - masks} intensity images, {masks} masks (≤ {UNIQUE_MAX_LISTED} unique values)")

    groups: dict[tuple[bool, int, str], list[ImageSummary]] = {}
    for summary in summaries.values():
        key = (summary.is_mask, summary.channel_count, str(summary.dtype))
        groups.setdefault(key, []).append(summary)
    for key in sorted(groups):
        print_group(groups[key])

    print_image_list(images, headers, summaries)


def main() -> None:
    """Dispatch on the path: directory overview, image overview, or an error."""
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    path = Path(sys.argv[1])
    if path.is_dir():
        describe_directory(path)
    elif is_image(path):
        describe_image(path)
    else:
        sys.exit(f"Not an image or directory: {path}")


if __name__ == "__main__":
    main()
