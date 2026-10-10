# Shell settings shared by every machine. Sourced from .zshrc before the
# OS file (shell/macos.zsh or shell/linux.zsh) and the machine file
# (machine/shell.zsh).

# Node version manager
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# Flutter / Dart
export PATH="$PATH:$HOME/dev/tools/flutter/bin"
export PATH="$PATH:$HOME/.pub-cache/bin"

# pipx, uv tools and our own scripts
export PATH="$PATH:$HOME/.local/bin"

# Rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# uv
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

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
    if cwd="$(command cat -- "$tmp")" && [[ -n "$cwd" ]] && [[ "$cwd" != "$PWD" ]]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
