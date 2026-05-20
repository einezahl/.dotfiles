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

# Reuse an existing ssh-agent across shells instead of spawning one per session.
SSH_ENV="$HOME/.ssh/agent.env"
start_agent() {
  ssh-agent -s | sed 's/^echo /#echo /' > "$SSH_ENV"
  chmod 600 "$SSH_ENV"
  . "$SSH_ENV" > /dev/null
}
if [ -f "$SSH_ENV" ]; then
  . "$SSH_ENV" > /dev/null
  kill -0 "$SSH_AGENT_PID" 2>/dev/null || start_agent
else
  start_agent
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export TERM=xterm-256color
export DOCKER_HOST=unix://$HOME/.docker/desktop/docker.sock

# yazi: `y` launches the file manager and cd's the shell into whatever
# directory you were in when you quit (Q). Plain `yazi` still works and
# leaves you in $PWD.
y() {
    local tmp cwd
    tmp=$(mktemp -t "yazi-cwd.XXXXXX")
    yazi "$@" --cwd-file="$tmp"
    if cwd=$(command cat -- "$tmp") && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
