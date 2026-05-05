# If not running interactively, for example when executing a script,
# don't do anything
[[ $- != *i* ]] && return

export BASH_SILENCE_DEPRECATION_WARNING=1
export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring

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

# Flutter
export PATH="$PATH:$HOME/dev/tools/flutter/bin"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="$PATH":"$HOME/.pub-cache/bin"

export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
export LDFLAGS="-L/opt/homebrew/opt/openssl@1.1/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@1.1/include"

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

alias v=nvim
alias t=tmux
alias cd=z
alias ..="cd .."
alias dot="cd $HOME/.dotfiles"
alias spy="source .venv/bin/activate"
alias ppy="export PYTHONPATH=$pwd:$PYTHONPATH"
alias copy="xclip -sel clip"

# Compatibility for loging into a remote terminal
alias ssh="TERM=xterm-256color ssh"

eval "$(zoxide init bash)"
eval "$(ssh-agent -s)" &> /dev/null

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
. "$HOME/.cargo/env"

PS1="\W:$"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export DATASET_ROOT_PATH='/home/admd/sciebo - Reclik, Tom (08QXP2@rwth-aachen.de)@rwth-aachen.sciebo.de/datasets/'
export TERM=xterm-256color
export DOCKER_HOST=unix://$HOME/.docker/desktop/docker.sock
