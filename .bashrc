# If not running interactively, for example when executing a script,
# don't do anything
[[ $- != *i* ]] && return

export BASH_SILENCE_DEPRECATION_WARNING=1

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
