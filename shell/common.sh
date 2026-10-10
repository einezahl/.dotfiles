# Shell settings shared by every machine. Sourced from .bashrc before the
# OS-specific file (shell/macos.sh or shell/linux.sh) and the machine file
# (machine/shell.sh).

# Node version manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# Flutter / Dart
export PATH="$PATH:$HOME/dev/tools/flutter/bin"
export PATH="$PATH:$HOME/.pub-cache/bin"

# Rust
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# uv
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

alias ll='ls -alF'
alias v=nvim
alias t=tmux
alias cd=z
alias ..="cd .."
alias dot='cd "$DOTFILES"'
alias spy="source .venv/bin/activate"
alias cenv="python3 -m venv .venv"
alias ppy='export PYTHONPATH="${PYTHONPATH}:${PWD}" && \
    source .venv/bin/activate && \
    echo "Exported PYTHONPATH"'

# Compatibility for logging into a remote terminal
alias ssh="TERM=xterm-256color ssh"

# yazi: quit with q to cd into the last visited directory
y() {
    local tmp cwd
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

eval "$(zoxide init bash)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

PS1="\W:$"
