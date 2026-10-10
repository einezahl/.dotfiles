# macOS-only shell settings. Sourced from shell/load.sh when $OSTYPE is darwin*.

export BASH_SILENCE_DEPRECATION_WARNING=1

# Homebrew-installed tools
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/opt/qt@5/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/openssl@1.1/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@1.1/include"
alias ibrew='/usr/local/Homebrew/bin/brew'

# MacPorts
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"

# npm global installs
[ -d "$HOME/.npm-global/bin" ] && export PATH="$HOME/.npm-global/bin:$PATH"

# jenv
if [ -d "$HOME/.jenv" ]; then
    export PATH="$HOME/.jenv/bin:$PATH"
    if command -v jenv >/dev/null 2>&1; then
        if [ -n "$ZSH_VERSION" ]; then
            eval "$(jenv init - zsh)"
        else
            eval "$(jenv init - bash)"
        fi
    fi
fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

alias copy="pbcopy"
