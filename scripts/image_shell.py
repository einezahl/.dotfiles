#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["numpy", "scikit-image", "tifffile", "imagecodecs", "imageio", "ipython", "matplotlib"]
# ///
"""Open IPython with an image loaded as `img` and the usual imaging libraries imported.

Usage: image_shell.py PATH

Namespace: np, plt (matplotlib.pyplot, interactive), ski (scikit-image),
iio (imageio.v3), tifffile, Path, path, and img (np.ndarray, loaded with
tifffile for TIFFs and imageio otherwise). If PATH is a directory, img is None
and path is the directory.
"""

import sys
from pathlib import Path

import imageio.v3 as iio
import matplotlib.pyplot as plt
import numpy as np
import skimage as ski
import tifffile
from IPython import start_ipython

# Importing image_info would otherwise write scripts/__pycache__ into the dotfiles repo.
sys.dont_write_bytecode = True
from image_info import is_image, load_image  # noqa: E402


def main() -> None:
    """Load the image (if PATH is one) and start IPython with the namespace above."""
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    path = Path(sys.argv[1]).resolve()

    img: np.ndarray | None = None
    if path.is_file() and is_image(path):
        img = load_image(path)
        print(f"img = {path.name}  shape={img.shape}  dtype={img.dtype}")
    else:
        print(f"path = {path}  (no image loaded)")
    print("loaded: np, plt, ski, iio, tifffile, Path, path, img")

    namespace = {
        "np": np,
        "plt": plt,
        "ski": ski,
        "iio": iio,
        "tifffile": tifffile,
        "Path": Path,
        "path": path,
        "img": img,
    }
    start_ipython(argv=["--no-banner", "--matplotlib"], user_ns=namespace)


if __name__ == "__main__":
    main()
