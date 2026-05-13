sudo apt update
sudo apt install i3
sudo apt install tmux -y
sudo apt install zsh -y

sudo apt install dunst
sudo apt install polybar
sudo apt install picom
sudo apt install rofi
sudo apt install feh
sudo apt install ripgrep
sudo apt install npm
sudo apt install lazygit
sudo apt install flameshot
sudo apt install keychain
# gpu-screen-recorder is not in Ubuntu apt repos; install via Flatpak:
# flatpak install -y flathub com.dec05eba.gpu_screen_recorder
# or build CLI from source: https://git.dec05eba.com/gpu-screen-recorder/about/

# Decide whether a downloaded tool needs (re)installing. Prints a status line
# and returns 0 to install, 1 to skip. (Re)installs when the latest version is
# unknown so a network/API hiccup never silently pins an outdated binary.
needs_install() {
    local name="$1" current="$2" latest="$3"
    if [ -z "$latest" ]; then
        echo "$name: latest version unknown, (re)installing"
        return 0
    elif [ "$current" = "$latest" ]; then
        echo "$name: up to date ($current), skipping"
        return 1
    else
        echo "$name: ${current:-not installed} -> $latest, installing"
        return 0
    fi
}

# neovim: latest stable AppImage, refreshed only when out of date.
nvim_latest=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest \
    | grep -oE '"tag_name": *"[^"]+"' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
nvim_current=$(nvim --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
if needs_install neovim "$nvim_current" "$nvim_latest"; then
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
    chmod u+x nvim-linux-x86_64.appimage
    sudo mv nvim-linux-x86_64.appimage /usr/local/bin/nvim
fi

sudo apt install pipx
pipx install black
pipx install uv
pipx install ast-grep-cli
pipx ensurepath

# bitwarden setup: official CLI + helpers for our rofi wrapper (scripts/bw_rofi.sh).
# The npm @bitwarden/cli package currently panics in Node's ESM runtime
# (WASM getrandom failure during encryption), so install the pre-built
# standalone binary from GitHub releases instead.
sudo apt install -y xdotool unzip jq xclip libsecret-tools
BW_VER=$(curl -s https://api.github.com/repos/bitwarden/clients/releases \
    | grep -oE '"tag_name": "cli-v[0-9.]+"' | head -1 \
    | sed -E 's/.*"cli-v([0-9.]+)".*/\1/')
bw_current=$(bw --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
if needs_install bw "$bw_current" "$BW_VER"; then
    curl -L -o /tmp/bw.zip "https://github.com/bitwarden/clients/releases/download/cli-v${BW_VER}/bw-oss-linux-${BW_VER}.zip"
    unzip -o /tmp/bw.zip -d /tmp/
    chmod +x /tmp/bw
    sudo mv /tmp/bw /usr/local/bin/bw
    rm /tmp/bw.zip
fi

# yazi: terminal file manager. Apt ships a stale version; grab the latest
# pre-built binary from GitHub releases. Recommended companions (zoxide, fzf,
# ripgrep, jq) are already installed above.
sudo apt install -y file
YAZI_VER=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest \
    | grep -oE '"tag_name": "v[0-9.]+"' | head -1 \
    | sed -E 's/.*"v([0-9.]+)".*/\1/')
yazi_current=$(yazi --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
if needs_install yazi "$yazi_current" "$YAZI_VER"; then
    curl -L -o /tmp/yazi.zip "https://github.com/sxyazi/yazi/releases/download/v${YAZI_VER}/yazi-x86_64-unknown-linux-gnu.zip"
    unzip -o /tmp/yazi.zip -d /tmp/
    sudo mv /tmp/yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/yazi
    sudo mv /tmp/yazi-x86_64-unknown-linux-gnu/ya   /usr/local/bin/ya
    rm -rf /tmp/yazi.zip /tmp/yazi-x86_64-unknown-linux-gnu
fi

# kitty: install from upstream (apt ships stale versions)
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/kitty
ln -sf ~/.local/kitty.app/bin/kitten ~/.local/bin/kitten
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop

# powerlevel10k theme for zsh (cloned into the dotfiles repo; gitignored)
if [ ! -d ~/.dotfiles/zsh/powerlevel10k ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.dotfiles/zsh/powerlevel10k
fi
# After install, run `chsh -s $(which zsh)` to set zsh as the login shell,
# then start a new zsh session and run `p10k configure` to generate ~/.p10k.zsh.
