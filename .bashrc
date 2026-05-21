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

# SSH keys via keychain — starts one ssh-agent and reuses it across shells,
# prompting for passphrases only on the first shell after boot. Every private
# key in ~/.ssh is detected by its "PRIVATE KEY" header, so this works no
# matter how the keys are named on a given machine.
ssh_keys=()
for key in "$HOME"/.ssh/*; do
  [ -f "$key" ] || continue
  IFS= read -r header < "$key" || continue
  case "$header" in
    *"PRIVATE KEY"*) ssh_keys+=("$key") ;;
  esac
done
eval "$(keychain --eval --quiet --agents ssh "${ssh_keys[@]}")"
unset ssh_keys key header

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
