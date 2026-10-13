# Project layout for scripts/tmux_sessionizer.sh on the MacBook. Sourced as
# bash. "root|depth": every directory exactly `depth` levels below `root` is a
# project, depth 0 makes `root` itself one. New projects go under the first root.
#
# Ported from the earlier macOS-only sessionizer, which listed git repos up to
# 1, 2 or 3 levels below these folders.
project_roots=(
    "$HOME/dev/projects|1"
    "$HOME/dev/code_review|1"
    "$HOME/dev/cv|1"
    "$HOME/dev/data_science_course|1"
    "$HOME/dev/experiments|1"
    "$HOME/dev/hashcode|1"
    "$HOME/dev/keyboard_layouts|1"
    "$HOME/dev/playground|1"
    "$HOME/dev/swift_projects|1"
    "$HOME/dev/tools|1"
    "$HOME/dev/apps|1"
    "$HOME/dev/apps|2"
    "$HOME/dev/competitions|1"
    "$HOME/dev/competitions|2"
    "$HOME/dev/ml|1"
    "$HOME/dev/ml|2"
    "$HOME/dev/solidity_projects|1"
    "$HOME/dev/solidity_projects|2"
    "$HOME/dev/whoishydra|1"
    "$HOME/dev/whoishydra|2"
    "$HOME/dev/crypto|1"
    "$HOME/dev/crypto|2"
    "$HOME/dev/crypto|3"
    "$HOME/dev/lectures|1"
    "$HOME/dev/lectures|2"
    "$HOME/dev/lectures|3"
    "$HOME/dev/phd|1"
    "$HOME/dev/phd|2"
    "$HOME/dev/phd|3"
    "$HOME/dev/tutorials|1"
    "$HOME/dev/tutorials|2"
    "$HOME/dev/tutorials|3"
    "$HOME/obsidian/phd|0"
    "$HOME/.dotfiles|0"
)

remote_projects=()
