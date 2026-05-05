sudo apt update
sudo apt install i3
sudo apt install tmux -y

sudo apt install dunst
sudo apt install polybar
sudo apt install picom
sudo apt install rofi
sudo apt install feh
sudo apt install ripgrep
sudo apt install npm
sudo apt install lazygit
sudo apt install flameshot
# gpu-screen-recorder is not in Ubuntu apt repos; install via Flatpak:
# flatpak install -y flathub com.dec05eba.gpu_screen_recorder
# or build CLI from source: https://git.dec05eba.com/gpu-screen-recorder/about/

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage
sudo mv nvim-linux-x86_64.appimage /usr/local/bin/nvim

sudo apt install pipx
pipx install black
pipx install uv
pipx install ast-grep-cli
pipx ensurepath

# kitty: install from upstream (apt ships stale versions)
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/kitty
ln -sf ~/.local/kitty.app/bin/kitten ~/.local/bin/kitten
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
