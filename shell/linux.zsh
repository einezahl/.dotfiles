# Linux-only shell settings. Sourced from .zshrc when $OSTYPE is linux*.
# SSH keys are loaded by keychain at the top of .zshrc, not here.

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init - zsh)"
    if pyenv commands | grep -qx virtualenv-init; then
        eval "$(pyenv virtualenv-init - zsh)"
    fi
fi

export TERM=xterm-256color
export DOCKER_HOST=unix://$HOME/.docker/desktop/docker.sock

# Go toolchain from the upstream tarball
export PATH="$PATH:/usr/local/go/bin"

# MTEX installation
export MTEX_PATH="$HOME/tools/mtex-7.1.0/"

# Homebrew/Linuxbrew, guarded so machines without it don't error every shell.
[[ -x /home/linuxbrew/.linuxbrew/bin/brew ]] && \
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# Node via fnm: the apt Node is too old for npm-based tools like Mason's
# language servers. After Homebrew so fnm's Node wins. Guarded for machines
# without fnm.
if [[ -x "$HOME/.local/share/fnm/fnm" ]]; then
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --use-on-cd --shell zsh)"
fi

alias copy="xclip -sel clip"
