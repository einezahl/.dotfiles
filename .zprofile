# zsh login shell entry point. Everything interactive lives in .zshrc.

if [[ "$OSTYPE" == "darwin"* ]]; then
  # needed for brew
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
