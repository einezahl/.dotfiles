export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
alias ll='ls -alF'

# Flutter
export PATH="$PATH:/Users/einezahl/dev/tools/flutter/bin"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Pyenv initialization
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
export LDFLAGS="-L/opt/homebrew/opt/openssl@1.1/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@1.1/include"

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin


