# Login shell entry point. Everything interactive lives in .bashrc.

if [[ "$OSTYPE" == "darwin"* ]]; then
  # needed for brew
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -r ~/.bashrc ]; then
  source ~/.bashrc
fi

# Tools that honor XDG read their config straight from this repo
export XDG_CONFIG_HOME="$HOME"/.dotfiles
