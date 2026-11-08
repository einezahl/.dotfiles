#!/usr/bin/env bash

# macOS counterpart of the i3 yazi scratchpad ($mod+m in i3/config): a floating
# kitty window running yazi that is shared by every space and toggled instead
# of navigated to. Bound to cmd - m in skhd/skhdrc. The window is recognised by
# the yabai rule in yabai/yabairc (app kitty, title yazi-scratch, scratchpad
# label below), which also makes it floating and sizes it.
#
# kitty's --title pins the OS window title, so yazi's own title updates do
# not break the match. zsh -l picks up Homebrew's PATH for yazi; the loop
# restarts yazi after `q` so the window never closes.

export PATH="/opt/homebrew/bin:$PATH"
label="yazi"

# Scratchpad window exists: show or hide it (--toggle fails if none has the label)
if yabai -m window --toggle "$label" 2>/dev/null; then
    exit 0
fi

open -na kitty --args --title yazi-scratch zsh -lc 'while true; do yazi; done'

# Wait for yabai to pick the new window up, then make sure it is visible
# (a freshly assigned scratchpad window may start hidden).
for _ in $(seq 1 50); do
    sleep 0.1
    visible=$(yabai -m query --windows \
        | jq -r --arg l "$label" '.[] | select(.scratchpad == $l) | .["is-visible"]')
    if [[ -n $visible ]]; then
        [[ $visible == false ]] && yabai -m window --toggle "$label"
        exit 0
    fi
done

echo "yazi scratchpad window did not appear" >&2
exit 1
