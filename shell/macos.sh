# macOS-only shell settings. Sourced from .bashrc when $OSTYPE is darwin*.

export BASH_SILENCE_DEPRECATION_WARNING=1

# Homebrew-installed tools
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/openssl@1.1/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@1.1/include"

# MacPorts
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

alias copy="pbcopy"
