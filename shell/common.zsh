# Shell settings shared by every machine. Sourced from .zshrc before the
# OS file (shell/macos.zsh or shell/linux.zsh) and the machine file
# (machine/shell.zsh).

# History: flush after every command so entries survive non-graceful exits
# (e.g. zsh inside a detached tmux session being killed at reboot).
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=200000
setopt APPEND_HISTORY INC_APPEND_HISTORY SHARE_HISTORY
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# vi-style command-line editing
bindkey -v

# Ctrl-F runs the tmux sessionizer (the same script as tmux's prefix + f).
tmux-sessionizer-widget() {
    BUFFER="$DOTFILES/scripts/tmux_sessionizer.sh"
    zle accept-line
}
zle -N tmux-sessionizer-widget
bindkey -M viins '^F' tmux-sessionizer-widget
bindkey -M vicmd '^F' tmux-sessionizer-widget

export EDITOR=nvim
export VISUAL=nvim
export CLAUDE_CODE_NO_FLICKER=1

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

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

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
