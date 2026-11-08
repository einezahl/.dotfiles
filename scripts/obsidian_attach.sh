#!/bin/sh
# Copy files into the Obsidian vault's attachment directory.
#
# usage: obsidian_attach.sh [HOVERED] -- [SELECTED...]
#
# Everything before `--` is the hovered file (zero or one path), everything
# after it the selected files. Selected files win when there are any, so the
# yazi binding can pass both and the script decides. Override the destination
# with OBSIDIAN_ATTACHMENTS. Existing names are never overwritten.
set -eu

dest="${OBSIDIAN_ATTACHMENTS:-$HOME/Documents/Obsidian/phd/_attachments}"

fail() {
  echo "obsidian_attach.sh: $*" >&2
  printf 'Press Enter to continue' >&2
  read -r _
  exit 1
}

hovered=""
while [ "$#" -gt 0 ] && [ "$1" != "--" ]; do
  hovered="$1"
  shift
done
[ "$#" -gt 0 ] && shift   # drop the `--`

if [ "$#" -eq 0 ]; then
  [ -n "$hovered" ] || fail "no file hovered or selected"
  set -- "$hovered"
fi

[ -d "$dest" ] || fail "attachment directory not found: $dest"

status=0
for src in "$@"; do
  name="$(basename "$src")"
  if [ -e "$dest/$name" ]; then
    echo "skipped, already exists: $name" >&2
    status=1
  else
    cp -p "$src" "$dest/$name"
    echo "attached: $name"
  fi
done

[ "$status" -eq 0 ] || fail "some files were not copied"
