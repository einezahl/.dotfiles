# Shared entry point for all machines. The actual settings live in
#   shell/common.sh      everything shared
#   shell/macos.sh       macOS only
#   shell/linux.sh       Linux only
#   machine/shell.sh     this machine only (machine -> machines/<name>, set by ./setup)

# If not running interactively, for example when executing a script,
# don't do anything
[[ $- != *i* ]] && return

export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

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

# Secrets and overrides that are not tracked in git
LOCALENV="$HOME/.config/localenv/"
if [ -d "$LOCALENV" ]; then
    for i in $(find -L "$LOCALENV" -type f); do
        source "$i"
    done
fi
