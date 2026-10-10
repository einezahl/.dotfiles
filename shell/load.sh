# Loads the shared, OS and machine layers. Sourced by .bashrc and .zshrc,
# so everything here and in the files it sources must work in both shells.
# Shell-specific integrations (completion, prompt, zoxide/fzf hooks) live
# in the rc files themselves.

export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

# Tools that honor XDG read their config straight from this repo
export XDG_CONFIG_HOME="$HOME/.dotfiles"

# Name of this machine, taken from the gitignored `machine` symlink
if [ -L "$DOTFILES/machine" ]; then
    export DOTFILES_MACHINE="$(basename "$(readlink "$DOTFILES/machine")")"
fi

source "$DOTFILES/shell/common.sh"

case "$OSTYPE" in
    darwin*) source "$DOTFILES/shell/macos.sh" ;;
    linux*)  source "$DOTFILES/shell/linux.sh" ;;
esac

[ -r "$DOTFILES/machine/shell.sh" ] && source "$DOTFILES/machine/shell.sh"
