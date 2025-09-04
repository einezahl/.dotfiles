# Only run on macOS

if [[ "$OSTYPE" == "darwin"* ]]; then
  # needed for brew
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -r ~/.bashrc ]; then
  source ~/.bashrc
fi

export XDG_CONFIG_HOME="$HOME"/.dotfiles
. "$HOME/.cargo/env"

##
# Your previous /Users/einezahl/.bash_profile file was backed up as /Users/einezahl/.bash_profile.macports-saved_2024-10-24_at_20:37:53
##

# MacPorts Installer addition on 2024-10-24_at_20:37:53: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.

