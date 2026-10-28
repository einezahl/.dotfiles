#!/bin/sh
# Open images in ksnip for quick annotation (crop, arrows, text, blur).
# On macOS the Homebrew cask installs only ksnip.app, so there is no `ksnip`
# binary on PATH and the app has to be launched through `open`.
set -eu

if [ "$#" -eq 0 ]; then
  echo "usage: $(basename "$0") IMAGE..." >&2
  exit 1
fi

if command -v ksnip >/dev/null 2>&1; then
  exec ksnip "$@"
elif [ "$(uname -s)" = "Darwin" ]; then
  exec open -a ksnip "$@"
else
  echo "ksnip is not installed (sudo apt install ksnip)" >&2
  exit 1
fi
