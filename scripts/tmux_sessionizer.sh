#!/usr/bin/env bash

remote_projects=(
    "hpcwork-kair|/hpcwork/tr434677/dev/super_resolution/KAIR|hpc"
)

local_dirs=$(find $HOME/dev/ -mindepth 3 -maxdepth 3 -type d; echo "$HOME/.dotfiles")
remote_names=$(printf '%s\n' "${remote_projects[@]}" | cut -d'|' -f1 | sed 's/^/[remote] /')

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(echo -e "$remote_names\n$local_dirs" | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

is_remote=false
remote_path="~/cluster/"
ssh_host="hpc"

if [[ $selected == "[remote] "* ]]; then
    is_remote=true
    remote_name="${selected#\[remote\] }"
    for entry in "${remote_projects[@]}"; do
        name=$(echo "$entry" | cut -d'|' -f1)
        if [[ "$name" == "$remote_name" ]]; then
            remote_path=$(echo "$entry" | cut -d'|' -f2)
            ssh_host=$(echo "$entry" | cut -d'|' -f3)
            break
        fi
    done
    selected_name=$(echo "$remote_name" | tr . _)
    local_mount="$HOME/cluster/$selected_name"
else
    selected_name=$(basename "$selected" | tr . _)
fi

create_session() {
    if [[ $is_remote == true ]]; then
        mkdir -p "$local_mount"
        
        remote_setup="cd $remote_path && source .venv/bin/activate && export PYTHONPATH=\$PYTHONPATH:$remote_path"
        local_setup="source $local_mount/.venv/bin/activate && export PYTHONPATH=\$PYTHONPATH:$local_mount"
        
        tmux new-session -ds $selected_name
        tmux rename-window -t $selected_name:1 'exec'
        tmux send-keys -t $selected_name:exec "ssh -t $ssh_host '$remote_setup && exec \$SHELL -l'" C-m
        
        tmux new-window -t $selected_name -n 'edit' -c "$HOME"
        tmux send-keys -t $selected_name:edit "mountpoint -q $local_mount || sshfs $ssh_host:$remote_path $local_mount -o reconnect,ServerAliveInterval=15 && cd $local_mount && $local_setup && nvim $local_mount" C-m
        
        tmux new-window -t $selected_name -n 'git' -c "$HOME"
        tmux send-keys -t $selected_name:git "mountpoint -q $local_mount || sshfs $ssh_host:$remote_path $local_mount -o reconnect,ServerAliveInterval=15 && cd $local_mount && $local_setup && lazygit" C-m

        tmux new-window -t $selected_name -n 'claude' -c "$HOME"
        tmux send-keys -t $selected_name:claude "mountpoint -q $local_mount || sshfs $ssh_host:$remote_path $local_mount -o reconnect,ServerAliveInterval=15 && cd $local_mount && $local_setup && claude" C-m
    else
        setup_commands="source .venv/bin/activate; export PYTHONPATH=\$PYTHONPATH:$selected"
        
        tmux new-session -ds $selected_name -c $selected
        tmux rename-window -t $selected_name:1 'exec'
        tmux send-keys -t $selected_name:exec "$setup_commands; echo 'Hello'" C-m
        
        tmux new-window -t $selected_name -n 'edit' -c $selected
        tmux send-keys -t $selected_name:edit "$setup_commands; nvim $selected" C-m
        
        tmux new-window -t $selected_name -n 'git' -c $selected
        tmux send-keys -t $selected_name:git "$setup_commands; lazygit" C-m

        tmux new-window -t $selected_name -n 'claude' -c $selected
        tmux send-keys -t $selected_name:claude "$setup_commands; claude" C-m
    fi
    
    tmux select-window -t $selected_name:edit
}

if ! tmux has-session -t="$selected_name" 2> /dev/null; then
    create_session
fi

# switch-client only works from inside a tmux client. A terminal launched
# outside tmux (e.g. the i3 autostart) must attach instead — otherwise the
# command exits immediately and takes the terminal window down with it.
if [[ -n $TMUX ]]; then
    tmux switch-client -t "$selected_name"
else
    tmux attach-session -t "$selected_name"
fi
