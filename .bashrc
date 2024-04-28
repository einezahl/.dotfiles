# If not running interactively, for example when executing a script,
# don't do anything
[[ $- != *i* ]] && return

export BASH_SILENCE_DEPRECATION_WARNING=1

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

# Export default dataset location
export DATASET_ROOT=/Users/einezahl/data

alias v=nvim
alias t=tmux
alias ..="cd .."
alias phd="cd /Users/einezahl/Documents/Obsidian/phd"
alias dot="cd /Users/einezahl/.dotfiles"

eval "$(zoxide init bash)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
. "$HOME/.cargo/env"

PS1="\W:$"
alias srplot='cd /Users/einezahl/dev/phd/super_resolution/sr_plots'
