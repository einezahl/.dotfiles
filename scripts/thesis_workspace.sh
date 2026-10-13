#!/usr/bin/env bash
# Set up the thesis workspace: a terminal running the thesis tmux session (see
# thesis_tmux.sh) and a zathura live preview of the compiled PDF tiled to its
# right, both on workspace $WS. Idempotent: re-running skips pieces that
# already exist.

THESIS_DIR="$HOME/Documents/thesis"
WS=2                   # workspace the thesis setup lives on
PREVIEW_WIDTH_PCT=40   # zathura's share of the workspace width

# Print the id of the first *mapped* window matching the xdotool search in
# "$@", waiting up to 10 s for it to appear. --onlyvisible matters: GTK apps
# (zathura) create an unmapped helper window first, which i3 never manages, so
# an i3-msg "[id=...]" on it silently matches nothing.
wait_for_window() {
    local wid
    for _ in $(seq 100); do
        wid=$(xdotool search --onlyvisible "$@" 2> /dev/null | head -n 1)
        if [[ -n $wid ]]; then
            echo "$wid"
            return 0
        fi
        sleep 0.1
    done
    return 1
}

# Terminal attached to the session. The assign rule in i3/config matches
# instance "thesis-tmux" and routes the window to workspace $WS.
if ! xdotool search --classname thesis-tmux > /dev/null 2>&1; then
    kitty --name thesis-tmux "$HOME/.dotfiles/scripts/thesis_tmux.sh" &
    # zathura (placed next) only tiles to the right of the terminal if the
    # terminal is already on the workspace.
    wait_for_window --classname thesis-tmux > /dev/null
fi

# Live preview. zathura has no --name/--class flag (and ignores RESOURCE_NAME),
# so an assign rule would capture every zathura window on the machine; instead
# find this instance's window via its pid and place it explicitly.
if ! pgrep -f "zathura $THESIS_DIR/main.pdf" > /dev/null; then
    zathura "$THESIS_DIR/main.pdf" &
    zpid=$!
    if wid=$(wait_for_window --pid "$zpid"); then
        i3-msg "[id=$wid] move to workspace number $WS" > /dev/null
        i3-msg "[id=$wid] resize set width $PREVIEW_WIDTH_PCT ppt" > /dev/null
    fi
fi
