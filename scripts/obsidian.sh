#!/usr/bin/env bash
# Launch Obsidian, scaled for the 4K monitor on the i3-4k machine.
# Obsidian saves its interface zoom (Settings → Appearance) per window but
# doesn't reliably restore it at startup, so on 4K the UI keeps coming up at
# 100%. Electron's --force-device-scale-factor scales the whole UI at launch
# instead, independent of Obsidian's own state. Keep Obsidian's zoom at 100%,
# or the two multiply. 1.73 ≈ the 173% (zoom level 3 = 1.2³) used before.
#
# Used by i3_autostart.sh and by the desktop entry ./setup writes to
# ~/.local/share/applications, so rofi and obsidian:// links get it too.

if ! command -v obsidian > /dev/null 2>&1; then
    echo "obsidian.sh: obsidian not found" >&2
    exit 1
fi

# Name of this machine, from the `machine -> machines/<name>` link ./setup makes
machine=$(basename "$(readlink "$HOME/.dotfiles/machine")")
case "$machine" in
    i3-4k) exec obsidian --force-device-scale-factor=1.73 "$@" ;;
    *) exec obsidian "$@" ;;
esac
