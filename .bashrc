# If not running interactively, for example when executing a script,
# don't do anything
[[ $- != *i* ]] && return

export BASH_SILENCE_DEPRECATION_WARNING=1

# Flush history after every command so entries survive non-graceful exits
# (e.g. bash inside a detached tmux session being killed at reboot).
shopt -s histappend
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoreboth
PROMPT_COMMAND='history -a'${PROMPT_COMMAND:+; $PROMPT_COMMAND}

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
alias ll='ls -alF'

alias cd=z
alias ..="cd .."
alias spy="source .venv/bin/activate"
alias ppy="export PYTHONPATH=$pwd:$PYTHONPATH"
alias copy="xclip -sel clip"

# Compatibility for loging into a remote terminal
alias ssh="TERM=xterm-256color ssh"

eval "$(zoxide init bash)"
eval "$(ssh-agent -s)" &> /dev/null

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export TERM=xterm-256color
export DOCKER_HOST=unix://$HOME/.docker/desktop/docker.sock
