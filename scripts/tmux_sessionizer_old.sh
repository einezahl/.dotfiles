#!/usr/bin/env bash
if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find $HOME/dev/ -mindepth 3 -maxdepth 3 -type d | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# Commands to run in each window
setup_commands="source .venv/bin/activate; export PYTHONPATH=\$PYTHONPATH:$selected"

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -ds $selected_name -c $selected
    tmux rename-window -t $selected_name:1 'exec'
    tmux send-keys -t $selected_name:exec "$setup_commands; echo 'Hello'" C-m
    
    tmux new-window -t $selected_name -n 'edit' -c $selected
    tmux send-keys -t $selected_name:edit "$setup_commands; nvim $selected" C-m
    
    tmux new-window -t $selected_name -n 'git' -c $selected
    tmux send-keys -t $selected_name:git "$setup_commands; lazygit" C-m
    
    tmux select-window -t $selected_name:edit
    tmux attach-session -t $selected_name
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected
    tmux rename-window -t $selected_name:1 'exec'
    tmux send-keys -t $selected_name:exec "$setup_commands" C-m
    
    tmux new-window -t $selected_name -n 'edit' -c $selected
    tmux send-keys -t $selected_name:edit "$setup_commands; nvim $selected" C-m
    
    tmux new-window -t $selected_name -n 'git' -c $selected
    tmux send-keys -t $selected_name:git "$setup_commands; lazygit" C-m
    
    tmux select-window -t $selected_name:edit
fi

tmux switch-client -t $selected_name
