#!/usr/bin/env bash
# Launch desktop apps at session start. Workspace placement is handled by
# `assign` rules in i3/config (matched on WM_CLASS / instance), so order and
# startup latency don't matter here — fire everything in parallel.

# Apply machine-specific display mode synchronously *before* launching apps.
# Otherwise kitty races xrandr and computes font dimensions against the
# pre-xrandr resolution, producing tiny fonts on 4K until you open a new term.
#
# The Samsung's DisplayPort link can come up a second *after* X starts. X then
# runs on a 640x480 dummy screen, the xrandr call below finds no DP-0 to set,
# and every app opens into a tiny window in the top-left corner. So wait (up
# to 5 s; normally it is there at once) until the monitor is reported connected.
wait_for_output() {
    for _ in $(seq 10); do
        xrandr --query | grep -q "^$1 connected" && return 0
        sleep 0.5
    done
    echo "i3_autostart: $1 still not connected, setting mode anyway" >&2
}

machine=$(tr -d '[:space:]' < "$HOME/.dotfiles/.machine" 2>/dev/null || true)
case "$machine" in
    4k)
        wait_for_output DP-0
        xrandr --output DP-0 --mode 3840x2160 --rate 143.99 --primary  # this panel tops out at 120 Hz; 143.99 was silently rejected
        # i3/config's feh may have scaled the wallpaper to the dummy screen.
        feh --bg-scale "$HOME/.dotfiles/wallpapers/forrest.jpeg"
        ;;
esac

# Run "$@" in the background if its first word names an available program.
# Returns non-zero otherwise, so per-machine candidates can be chained with
# `||`: the same app is installed differently across machines (snap vs
# AppImage vs flatpak vs /opt). A machine that lacks every candidate gets a
# logged warning instead of a silent no-op.
try_launch() {
    command -v "$1" > /dev/null 2>&1 || return 1
    "$@" &
}

try_launch /opt/zotero/zotero || try_launch /snap/bin/zotero-snap \
    || echo "i3_autostart: zotero not found" >&2

try_launch flatpak run app.zen_browser.zen \
    || try_launch "$HOME/tools/browser/zen-x86_64.AppImage" \
    || echo "i3_autostart: zen not found" >&2

try_launch obsidian || echo "i3_autostart: obsidian not found" >&2

# Not needed on the hd machine.
if [[ $machine != hd ]]; then
    try_launch keepassxc || echo "i3_autostart: keepassxc not found" >&2
fi

# i3 doesn't run ~/.config/autostart entries, so Nextcloud has to be started here.
try_launch nextcloud || echo "i3_autostart: nextcloud not found" >&2

# Not needed on the hd machine.
if [[ $machine != hd ]]; then
    try_launch /opt/cisco/secureclient/bin/vpnui \
        || echo "i3_autostart: cisco secure client not found" >&2
fi

# Tag this terminal with a distinct instance name so the assign rule sends
# only this specific window to workspace 1 (other kitty windows are
# unaffected and open wherever they're launched from). kitty sets the WM_CLASS
# instance via --name; the assign rule matches on instance="tmux-sessionizer".
kitty --name tmux-sessionizer "$HOME/.dotfiles/scripts/tmux_sessionizer.sh" &
