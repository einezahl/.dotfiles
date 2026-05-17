#!/usr/bin/env bash
# Launch desktop apps at session start. Workspace placement is handled by
# `assign` rules in i3/config (matched on WM_CLASS / instance), so order and
# startup latency don't matter here — fire everything in parallel.

/opt/zotero/zotero &
flatpak run app.zen_browser.zen &
obsidian &
/opt/cisco/secureclient/bin/vpnui &

# Tag this terminal with a distinct instance name so the assign rule sends
# only this specific window to workspace 1 (other alacritty windows are
# unaffected and open wherever they're launched from).
alacritty --class Alacritty,tmux-sessionizer -e "$HOME/.dotfiles/scripts/tmux_sessionizer.sh" &
