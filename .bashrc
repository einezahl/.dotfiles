# bash entry point. The settings live in shell/ (see shell/load.sh); only
# bash-specific integrations are here. .zshrc is the zsh counterpart.

# If not running interactively, for example when executing a script,
# don't do anything
[[ $- != *i* ]] && return

source "$HOME/.dotfiles/shell/load.sh"

# zoxide and fzf completions need bash 4+. macOS ships bash 3.2, where the
# completion code does not even parse, so only the commands are loaded there.
if (( BASH_VERSINFO[0] >= 4 )); then
    eval "$(zoxide init bash)"
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
else
    eval "$(zoxide init bash | sed -n '1,/^# Load completions/p')"
fi

[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

PS1="\W:$"

source "$HOME/.dotfiles/shell/localenv.sh"
