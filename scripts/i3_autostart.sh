#!/usr/bin/env bash
# Launch desktop apps at session start. Workspace placement is handled by
# `assign` rules in i3/config (matched on WM_CLASS / instance), so order and
# startup latency don't matter here — fire everything in parallel.

# Apply machine-specific display mode synchronously *before* launching apps.
# Otherwise alacritty races xrandr and computes font dimensions against the
# pre-xrandr resolution, producing tiny fonts on 4K until you open a new term.
machine=$(tr -d '[:space:]' < "$HOME/.dotfiles/.machine" 2>/dev/null || true)
case "$machine" in
    4k) xrandr --output DP-0 --mode 3840x2160 --rate 143.99 ;;
esac

/opt/zotero/zotero &
flatpak run app.zen_browser.zen &
obsidian &

# Tag this terminal with a distinct instance name so the assign rule sends
# only this specific window to workspace 1 (other alacritty windows are
# unaffected and open wherever they're launched from).
alacritty --class Alacritty,tmux-sessionizer -e "$HOME/.dotfiles/scripts/tmux_sessionizer.sh" &
