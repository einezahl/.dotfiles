#!/usr/bin/env bash
# Launch desktop apps at session start. Workspace placement is handled by
# `assign` rules in i3/config (matched on WM_CLASS / instance), so order and
# startup latency don't matter here — fire everything in parallel.

# Apply machine-specific display mode synchronously *before* launching apps.
# Otherwise kitty races xrandr and computes font dimensions against the
# pre-xrandr resolution, producing tiny fonts on 4K until you open a new term.
machine=$(tr -d '[:space:]' < "$HOME/.dotfiles/.machine" 2>/dev/null || true)
case "$machine" in
    4k) xrandr --output DP-0 --mode 3840x2160 --rate 120 ;;  # this panel tops out at 120 Hz; 143.99 was silently rejected
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

try_launch keepassxc || echo "i3_autostart: keepassxc not found" >&2

# i3 doesn't run ~/.config/autostart entries, so Nextcloud has to be started here.
try_launch nextcloud || echo "i3_autostart: nextcloud not found" >&2

try_launch /opt/cisco/secureclient/bin/vpnui \
    || echo "i3_autostart: cisco secure client not found" >&2

# Tag this terminal with a distinct instance name so the assign rule sends
# only this specific window to workspace 1 (other kitty windows are
# unaffected and open wherever they're launched from). kitty sets the WM_CLASS
# instance via --name; the assign rule matches on instance="tmux-sessionizer".
kitty --name tmux-sessionizer "$HOME/.dotfiles/scripts/tmux_sessionizer.sh" &

# True once the shared ssh-agent started by keychain holds at least one key.
# --query/--nolock only reads the agent info keychain wrote to ~/.keychain,
# so this never touches keychain's lock while another instance is prompting.
ssh_keys_loaded() {
    eval "$(keychain --query --quiet --nolock --agents ssh 2> /dev/null)"
    export SSH_AUTH_SOCK
    ssh-add -l > /dev/null 2>&1
}

# The thesis terminal loads the SSH keys before spawning its tmux windows (see
# thesis_tmux.sh), exactly like the sessionizer terminal above. Launched in
# parallel they'd both prompt for the passphrase: keychain's lock only waits
# 5 s before it is taken by force. So wait until the sessionizer terminal on
# workspace 1 — the one in view after login — has loaded the keys, and the
# passphrase is asked for exactly once, there. Give up after 5 min (e.g. the
# prompt was dismissed) and launch anyway; the thesis terminal then prompts on
# its own.
launch_thesis_after_ssh_keys() {
    for _ in $(seq 600); do
        ssh_keys_loaded && break
        sleep 0.5
    done
    "$HOME/.dotfiles/scripts/thesis_workspace.sh"
}
launch_thesis_after_ssh_keys &
