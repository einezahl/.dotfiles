# Linux-only shell settings. Sourced from .bashrc when $OSTYPE is linux*.

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
    if pyenv commands | grep -qx virtualenv-init; then
        eval "$(pyenv virtualenv-init -)"
    fi
fi

# ssh agent
eval "$(ssh-agent -s)" &> /dev/null

alias copy="xclip -sel clip"
