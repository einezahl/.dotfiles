#!/usr/bin/env bash
# Run the trained slip line / crack detectors on one image and reveal the
# overlay in yazi.
#
# usage: image_detect.sh slip|crack|both IMAGE
#
# Wraps `slip-detect predict` from the model training repository, so the
# detectors, preprocessing and overlay are exactly the ones used in evaluation.
# The pixel size comes from the "Field of view" in <stem>_metadata.txt beside
# the image; without it the script asks for the field of view in µm.
#
# Overrides (environment):
#   SLIP_DETECT_REPO   training repository (default ~/dev/indents/slip_lines/slip_line_detection_model_training)
#   SLIP_DETECT_SLIP   run name or best.pt for slip lines (default I_dinov3_b_ft)
#   SLIP_DETECT_CRACK  run name or best.pt for cracks (default CR_I_dinov3_b_ft)
set -euo pipefail

repo="${SLIP_DETECT_REPO:-$HOME/dev/indents/slip_lines/slip_line_detection_model_training}"
slip_run="${SLIP_DETECT_SLIP:-I_dinov3_b_ft}"
crack_run="${SLIP_DETECT_CRACK:-CR_I_dinov3_b_ft}"

# yazi --block returns to the file list as soon as the script exits, so keep
# errors on screen until a key is pressed.
fail() {
  echo "$*" >&2
  read -rsn1 -p "press any key" </dev/tty
  exit 1
}

# A run name resolves to runs/<name>/best.pt, or to the MLflow store once
# `slip-detect track --purge` has removed the local run directory.
checkpoint() {
  local run="$1"
  if [[ "$run" == *.pt ]]; then
    echo "$run"
  elif [[ -f "$repo/runs/$run/best.pt" ]]; then
    echo "$repo/runs/$run/best.pt"
  else
    echo "mlflow:$run"
  fi
}

# Inside yazi ($YAZI_ID is set for its shells) jump to the overlay so it shows in
# the preview pane; outside yazi just print where it is.
show_result() {
  if [[ -n "${YAZI_ID:-}" ]]; then
    ya emit reveal "$1"
  else
    echo "$1"
  fi
}

[[ $# -eq 2 ]] || fail "usage: $(basename "$0") slip|crack|both IMAGE"
mode="$1"
image="$(realpath "$2")"
[[ -f "$image" ]] || fail "not a file: $image"
[[ -d "$repo" ]] || fail "training repository not found: $repo (set SLIP_DETECT_REPO)"

detectors=()
case "$mode" in
  slip) detectors=(--detector "$(checkpoint "$slip_run")") ;;
  crack) detectors=(--detector "$(checkpoint "$crack_run")") ;;
  both) detectors=(--detector "$(checkpoint "$slip_run")" --detector "$(checkpoint "$crack_run")") ;;
  *) fail "unknown mode '$mode': choose slip, crack or both" ;;
esac

stem="$(basename "${image%.*}")"
metadata="$(dirname "$image")/${stem}_metadata.txt"
scale=()
# slip-detect reads the pixel size from the "Field of view:" line of the older
# TESCAN export; the Key=Value export (e.g. Lukas' E-T images) has no field of
# view at all, so both cases fall back to asking.
if ! grep -qs "^Field of view:" "$metadata"; then
  read -rp "no field of view in ${stem}_metadata.txt; field of view in µm [7]: " fov </dev/tty
  fov="${fov:-7}"
  width="$(uv run --quiet --project "$repo" python -c \
    'import sys, skimage.io; print(skimage.io.imread(sys.argv[1]).shape[1])' "$image")"
  nm_per_px="$(awk -v fov="$fov" -v w="$width" 'BEGIN { printf "%.4f", fov * 1000 / w }')"
  echo "$width px across ${fov} µm -> $nm_per_px nm/px"
  scale=(--nm-per-px "$nm_per_px")
fi

out="${XDG_CACHE_HOME:-$HOME/.cache}/image_detect/$mode"
echo "running $mode detection on $(basename "$image") ..."
(cd "$repo" && uv run --quiet slip-detect predict "${detectors[@]}" --images "$image" \
  "${scale[@]}" --scores --out "$out") || fail "slip-detect predict failed"

show_result "$out/$stem.png"
