export XDG_CONFIG_HOME="$HOME"/.config
OLD_CONFIG="$XDG_CONFIG_HOME"/old_config
mkdir -p "$XDG_CONFIG_HOME"/bash
mkdir -p "$XDG_CONFIG_HOME"/alacritty
mkdir -p "$OLD_CONFIG"

[ -L "$XDG_CONFIG_HOME"/alacritty/alacritty.toml ] && unlink "$XDG_CONFIG_HOME"/alacritty/alacritty.toml
[ -L "$HOME"/.bash_profile ] && unlink "$HOME"/.bash_profile
[ -L "$HOME"/.bashrc ] && unlink "$HOME"/.bashrc
[ -L "$HOME"/.tmux.conf ] && unlink "$HOME"/.tmux.conf
[ -L "$XDG_CONFIG_HOME"/nvim ] && unlink "$XDG_CONFIG_HOME"/nvim
[ -L "$XDG_CONFIG_HOME"/dunst ] && unlink "$XDG_CONFIG_HOME"/dunst
[ -L "$XDG_CONFIG_HOME"/i3 ] && unlink "$XDG_CONFIG_HOME"/i3
[ -L "$XDG_CONFIG_HOME"/picom ] && unlink "$XDG_CONFIG_HOME"/picom
[ -L "$XDG_CONFIG_HOME"/polybar ] && unlink "$XDG_CONFIG_HOME"/polybar
[ -L "$XDG_CONFIG_HOME"/rofi ] && unlink "$XDG_CONFIG_HOME"/rofi

[ -f "$XDG_CONFIG_HOME"/alacritty/alacritty.toml ] && mv "$XDG_CONFIG_HOME"/alacritty/alacritty.toml "$OLD_CONFIG"/alacritty/alacritty.toml
[ -f "$HOME"/.bash_profile ] && mv "$HOME"/.bash_profile "$OLD_CONFIG"/.bash_profile
[ -f "$HOME"/.bashrc ] && mv "$HOME"/.bashrc "$OLD_CONFIG"/.bashrc
[ -f "$HOME"/.tmux.conf ] && mv "$HOME"/.tmux.conf "$OLD_CONFIG"/.tmux.conf
[ -d "$XDG_CONFIG_HOME"/nvim ] && mv "$XDG_CONFIG_HOME"/nvim "$OLD_CONFIG"/nvim
[ -d "$XDG_CONFIG_HOME"/dunst ] && mv "$XDG_CONFIG_HOME"/dunst "$OLD_CONFIG"/dunst
[ -d "$XDG_CONFIG_HOME"/i3 ] && mv "$XDG_CONFIG_HOME"/i3 "$OLD_CONFIG"/i3
[ -d "$XDG_CONFIG_HOME"/picom ] && mv "$XDG_CONFIG_HOME"/picom "$OLD_CONFIG"/picom
[ -d "$XDG_CONFIG_HOME"/polybar ] && mv "$XDG_CONFIG_HOME"/polybar "$OLD_CONFIG"/polybar
[ -d "$XDG_CONFIG_HOME"/rofi ] && mv "$XDG_CONFIG_HOME"/rofi "$OLD_CONFIG"/rofi

ln -sf "$PWD/alacritty.toml" "$XDG_CONFIG_HOME"/alacritty/alacritty.toml
ln -sf "$PWD/.bash_profile" "$HOME"/.bash_profile
ln -sf "$PWD/.bashrc" "$HOME"/.bashrc
ln -sf "$PWD/.tmux.conf" "$HOME"/.tmux.conf
ln -sf "$PWD/nvim" "$XDG_CONFIG_HOME"/nvim
ln -sf "$PWD/dunst" "$XDG_CONFIG_HOME"/dunst
ln -sf "$PWD/i3" "$XDG_CONFIG_HOME"/i3
ln -sf "$PWD/picom" "$XDG_CONFIG_HOME"/picom
ln -sf "$PWD/polybar" "$XDG_CONFIG_HOME"/polybar
ln -sf "$PWD/rofi" "$XDG_CONFIG_HOME"/rofi

