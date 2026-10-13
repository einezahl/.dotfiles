#!/usr/bin/env bash
# Launch Obsidian, scaled for the 4K monitor on the 4k machine profile.
# Obsidian saves its interface zoom (Settings → Appearance) per window but
# doesn't reliably restore it at startup, so on 4K the UI keeps coming up at
# 100%. Electron's --force-device-scale-factor scales the whole UI at launch
# instead, independent of Obsidian's own state. Keep Obsidian's zoom at 100%,
# or the two multiply. 1.73 ≈ the 173% (zoom level 3 = 1.2³) used before.
#
# Used by i3_autostart.sh and by the desktop entry setup.sh writes to
# ~/.local/share/applications, so rofi and obsidian:// links get it too.

if ! command -v obsidian > /dev/null 2>&1; then
    echo "obsidian.sh: obsidian not found" >&2
    exit 1
fi

machine=$(tr -d '[:space:]' < "$HOME/.dotfiles/.machine" 2>/dev/null || true)
case "$machine" in
    4k) exec obsidian --force-device-scale-factor=1.73 "$@" ;;
    *) exec obsidian "$@" ;;
esac
