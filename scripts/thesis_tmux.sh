#!/usr/bin/env bash
# Runs *inside* the thesis terminal (launched by thesis_workspace.sh): load the
# SSH keys, create the thesis tmux session if it doesn't exist yet, attach.
#
# Loading the keys here, in the terminal, before any tmux window exists is what
# keeps the passphrase prompt to a single one. Creating the session from the i3
# exec instead left every window's shell prompting on its own pty, and the
# command typed ahead via `tmux send-keys` (nvim, lazygit, latexmk, ...) was
# swallowed by that prompt. Same pattern as tmux_sessionizer.sh.
source "$HOME/.dotfiles/scripts/ssh_keychain.sh"

THESIS_DIR="$HOME/Documents/thesis"
SESSION="thesis"

# Same window layout as tmux_sessionizer.sh (exec/edit/git/claude) plus a
# 'build' window running the latexmk watcher.
if ! tmux has-session -t="$SESSION" 2> /dev/null; then
    tmux new-session -ds "$SESSION" -c "$THESIS_DIR"
    tmux rename-window -t "$SESSION:1" 'exec'

    tmux new-window -t "$SESSION" -n 'edit' -c "$THESIS_DIR"
    tmux send-keys -t "$SESSION:edit" "nvim $THESIS_DIR" C-m

    tmux new-window -t "$SESSION" -n 'git' -c "$THESIS_DIR"
    tmux send-keys -t "$SESSION:git" "lazygit" C-m

    tmux new-window -t "$SESSION" -n 'claude' -c "$THESIS_DIR"
    tmux send-keys -t "$SESSION:claude" "claude" C-m

    # latexmk recompiles on every .tex save; zathura auto-reloads the PDF.
    # -view=none because zathura is launched by thesis_workspace.sh as an i3
    # window, not as a latexmk child (which would tie its lifetime to the
    # watcher).
    tmux new-window -t "$SESSION" -n 'build' -c "$THESIS_DIR"
    tmux send-keys -t "$SESSION:build" "latexmk -pvc -view=none main.tex" C-m

    tmux select-window -t "$SESSION:edit"
fi

# switch-client only works from inside a tmux client. This normally runs in a
# fresh terminal outside tmux, which must attach instead — otherwise the
# command exits immediately and takes the terminal window down with it.
if [[ -n $TMUX ]]; then
    tmux switch-client -t "$SESSION"
else
    tmux attach-session -t "$SESSION"
fi
