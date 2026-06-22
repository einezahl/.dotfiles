#!/usr/bin/env bash
export XDG_CONFIG_HOME="$HOME"/.config
OLD_CONFIG="$XDG_CONFIG_HOME"/old_config
mkdir -p "$XDG_CONFIG_HOME"/bash
mkdir -p "$XDG_CONFIG_HOME"/kitty
mkdir -p "$XDG_CONFIG_HOME"/alacritty
mkdir -p "$HOME"/.claude
mkdir -p "$OLD_CONFIG"

[ -L "$XDG_CONFIG_HOME"/kitty/kitty.conf ] && unlink "$XDG_CONFIG_HOME"/kitty/kitty.conf
[ -L "$XDG_CONFIG_HOME"/alacritty/alacritty.toml ] && unlink "$XDG_CONFIG_HOME"/alacritty/alacritty.toml
[ -L "$HOME"/.bash_profile ] && unlink "$HOME"/.bash_profile
[ -L "$HOME"/.bashrc ] && unlink "$HOME"/.bashrc
[ -L "$HOME"/.zshrc ] && unlink "$HOME"/.zshrc
[ -L "$HOME"/.p10k.zsh ] && unlink "$HOME"/.p10k.zsh
[ -L "$HOME"/.tmux.conf ] && unlink "$HOME"/.tmux.conf
[ -L "$XDG_CONFIG_HOME"/nvim ] && unlink "$XDG_CONFIG_HOME"/nvim
[ -L "$XDG_CONFIG_HOME"/dunst ] && unlink "$XDG_CONFIG_HOME"/dunst
[ -L "$XDG_CONFIG_HOME"/i3 ] && unlink "$XDG_CONFIG_HOME"/i3
[ -L "$XDG_CONFIG_HOME"/picom ] && unlink "$XDG_CONFIG_HOME"/picom
[ -L "$XDG_CONFIG_HOME"/polybar ] && unlink "$XDG_CONFIG_HOME"/polybar
[ -L "$XDG_CONFIG_HOME"/rofi ] && unlink "$XDG_CONFIG_HOME"/rofi
[ -L "$HOME"/.claude/CLAUDE.md ] && unlink "$HOME"/.claude/CLAUDE.md
[ -L "$HOME"/.claude/ml-projects.md ] && unlink "$HOME"/.claude/ml-projects.md

[ -f "$XDG_CONFIG_HOME"/kitty/kitty.conf ] && mv "$XDG_CONFIG_HOME"/kitty/kitty.conf "$OLD_CONFIG"/kitty/kitty.conf
[ -f "$XDG_CONFIG_HOME"/alacritty/alacritty.toml ] && mv "$XDG_CONFIG_HOME"/alacritty/alacritty.toml "$OLD_CONFIG"/alacritty/alacritty.toml
[ -f "$HOME"/.bash_profile ] && mv "$HOME"/.bash_profile "$OLD_CONFIG"/.bash_profile
[ -f "$HOME"/.bashrc ] && mv "$HOME"/.bashrc "$OLD_CONFIG"/.bashrc
[ -f "$HOME"/.zshrc ] && mv "$HOME"/.zshrc "$OLD_CONFIG"/.zshrc
[ -f "$HOME"/.p10k.zsh ] && mv "$HOME"/.p10k.zsh "$OLD_CONFIG"/.p10k.zsh
[ -f "$HOME"/.tmux.conf ] && mv "$HOME"/.tmux.conf "$OLD_CONFIG"/.tmux.conf
[ -d "$XDG_CONFIG_HOME"/nvim ] && mv "$XDG_CONFIG_HOME"/nvim "$OLD_CONFIG"/nvim
[ -d "$XDG_CONFIG_HOME"/dunst ] && mv "$XDG_CONFIG_HOME"/dunst "$OLD_CONFIG"/dunst
[ -d "$XDG_CONFIG_HOME"/i3 ] && mv "$XDG_CONFIG_HOME"/i3 "$OLD_CONFIG"/i3
[ -d "$XDG_CONFIG_HOME"/picom ] && mv "$XDG_CONFIG_HOME"/picom "$OLD_CONFIG"/picom
[ -d "$XDG_CONFIG_HOME"/polybar ] && mv "$XDG_CONFIG_HOME"/polybar "$OLD_CONFIG"/polybar
[ -d "$XDG_CONFIG_HOME"/rofi ] && mv "$XDG_CONFIG_HOME"/rofi "$OLD_CONFIG"/rofi
[ -f "$HOME"/.claude/CLAUDE.md ] && mv "$HOME"/.claude/CLAUDE.md "$OLD_CONFIG"/CLAUDE.md
[ -f "$HOME"/.claude/ml-projects.md ] && mv "$HOME"/.claude/ml-projects.md "$OLD_CONFIG"/ml-projects.md

ln -sf "$PWD/kitty/kitty.conf" "$XDG_CONFIG_HOME"/kitty/kitty.conf
ln -sf "$PWD/alacritty.toml" "$XDG_CONFIG_HOME"/alacritty/alacritty.toml
ln -sf "$PWD/.bash_profile" "$HOME"/.bash_profile
ln -sf "$PWD/.bashrc" "$HOME"/.bashrc
ln -sf "$PWD/.zshrc" "$HOME"/.zshrc
ln -sf "$PWD/.p10k.zsh" "$HOME"/.p10k.zsh
ln -sf "$PWD/.tmux.conf" "$HOME"/.tmux.conf
ln -sf "$PWD/nvim" "$XDG_CONFIG_HOME"/nvim
ln -sf "$PWD/dunst" "$XDG_CONFIG_HOME"/dunst
ln -sf "$PWD/i3" "$XDG_CONFIG_HOME"/i3
ln -sf "$PWD/picom" "$XDG_CONFIG_HOME"/picom
ln -sf "$PWD/polybar" "$XDG_CONFIG_HOME"/polybar
ln -sf "$PWD/rofi" "$XDG_CONFIG_HOME"/rofi
ln -sf "$PWD/CLAUDE.md" "$HOME"/.claude/CLAUDE.md
ln -sf "$PWD/ml-projects.md" "$HOME"/.claude/ml-projects.md

# Per-machine profile: read $PWD/.machine (4k|hd). Prompt once if missing.
if [ ! -f "$PWD/.machine" ]; then
	echo "No .machine flag found. Pick this machine's profile:"
	select machine in 4k hd; do
		case "$machine" in
			4k|hd) echo "$machine" > "$PWD/.machine"; break ;;
		esac
	done
fi
machine="$(tr -d '[:space:]' < "$PWD/.machine")"
case "$machine" in
	4k|hd) ;;
	*) echo "Unknown machine flag '$machine' in $PWD/.machine (expected 4k or hd)" >&2; exit 1 ;;
esac
ln -sf "$PWD/i3/machine/${machine}.conf" "$PWD/i3/machine/current.conf"
ln -sf "$PWD/rofi/machine-${machine}.rasi" "$PWD/rofi/machine.rasi"
ln -sf "$PWD/polybar/cuts/sizes-${machine}.ini" "$PWD/polybar/cuts/machine.ini"
ln -sf "$PWD/kitty/font-${machine}.conf" "$PWD/kitty/machine.conf"

