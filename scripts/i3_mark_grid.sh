#!/usr/bin/env bash
# Stamp the tiled windows of the focused workspace with grid marks for the
# 2x2 terminal-grid jump keys ($mod+Ctrl+u/i/j/k in i3/config).
#
# Windows are sorted top-to-bottom, then left-to-right:
#   grid1 = top-left     grid2 = top-right
#   grid3 = bottom-left  grid4 = bottom-right
# Re-run after rearranging the grid. i3 marks are global, so grid1-grid4
# always point at whichever workspace was stamped last.

set -euo pipefail

workspace=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused).name')

# Floating windows live under .floating_nodes, so recursing .nodes only
# walks the tiled layout and excludes them automatically.
mapfile -t ids < <(
    i3-msg -t get_tree | jq -r --arg ws "$workspace" '
        .. | objects
        | select(.type? == "workspace" and .name == $ws)
        | [recurse(.nodes[]?) | select(.window != null)]
        | sort_by(.rect.y, .rect.x)
        | .[].id
    '
)

for i in "${!ids[@]}"; do
    i3-msg "[con_id=${ids[$i]}] mark grid$((i + 1))" >/dev/null
done

dunstify -a "i3" -r 200 "Grid marked" "${#ids[@]} window(s)"
