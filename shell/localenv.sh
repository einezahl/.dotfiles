# Secrets and overrides that are not tracked in git. Sourced last by
# .bashrc and .zshrc so they can override anything set before.

LOCALENV="$HOME/.config/localenv/"
if [ -d "$LOCALENV" ]; then
    for i in $(find -L "$LOCALENV" -type f); do
        source "$i"
    done
fi
