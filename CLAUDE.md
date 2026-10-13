# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Personal dotfiles for three machines: a MacBook (yabai/skhd, keybindings kept close to i3) and two Ubuntu machines running i3. All of them use zsh with powerlevel10k; bash is not supported. One branch (`main`) serves all of them. Shared configs live at the top level, OS-specific shell settings in `shell/`, and everything that differs per machine (display layout, VPN helpers, font sizes, project list) in `machines/<name>/`. The `setup` script symlinks tracked configs into `$HOME` / `~/.config`, so edits here take effect immediately through those symlinks — there is no build step.

## Setup

```sh
cd ~/.dotfiles && ./setup <machine>     # machine = a directory under machines/
```

`./setup` with no argument keeps the previously chosen machine (or maps an old `.machine` flag `4k`/`hd` to `i3-4k`/`i3-hd`) or shows a menu. It records the choice as the gitignored symlink `machine -> machines/<name>` and links `.zshrc`, `.zprofile`, `.tmux.conf`, `alacritty.toml`, `kitty/`, `nvim/`, `yazi/`, every file in `scripts/` into `~/.local/bin`, and `claude/CLAUDE.md` / `claude/ml-projects.md` into `~/.claude/`, plus `yabai/` and `skhd/` on macOS and `i3/`, `polybar/`, `rofi/`, `dunst/`, `picom/`, `zathura/`, the wallpaper systemd timer and an Obsidian desktop entry on Linux. Existing files at a target are moved to `~/.config/old_config/<timestamp>/`, and `~/.bashrc` / `~/.bash_profile` links from older versions of this repo are removed. `install.sh` installs the i3 stack on Ubuntu (apt packages, Neovim AppImage, tmux built from source, fzf, yazi, kitty, powerlevel10k into `zsh/`). Switching a machine's login shell is a manual step: `chsh -s "$(command -v zsh)"`.

On macOS `XDG_CONFIG_HOME` is overridden to `$HOME/.dotfiles` (see `.zshrc`), so tools started from a shell read directly from this repo; the symlinks exist for tools started by the window manager, which do not see that variable. The i3 machines keep `~/.config` and reach the configs only through the symlinks.

## The machine mechanism

Every config that differs per machine includes a file from the `machine` symlink:

| Consumer | Includes | Holds |
|---|---|---|
| `.zshrc` | `machine/shell.zsh` | VPN helpers, machine-only aliases and exports |
| `i3/config` | `machine/i3.conf` | xrandr layout, `workspace N output` |
| `polybar/cuts/config.ini` | `machine/polybar.ini` | `[machine]` section: `monitor`, `network-interface`, font sizes, `bar-width`, referenced as `${machine.<key>}` |
| `alacritty.toml` | `machine/alacritty.toml` | font size, decorations |
| `kitty/kitty.conf` | `machine/kitty.conf` | font size, macOS option key |
| `rofi/main.rasi` | `machine/rofi.rasi` | font size (i3 machines only) |
| `scripts/tmux_sessionizer.sh` | `machine/sessionizer.sh` | `project_roots` / `remote_projects` (optional, defaults to `~/dev` at depth 3) |

`.zshrc` also exports `DOTFILES_MACHINE` (the directory name) for ad-hoc checks. Scripts started outside a shell (`scripts/i3_autostart.sh`, `scripts/obsidian.sh`) read the name from the symlink themselves. Adding a machine means creating `machines/<name>/` with these files and running `./setup <name>`. OS-level differences (clipboard tool, Homebrew paths, pyenv) do not belong in `machines/`; they go in `shell/macos.zsh` or `shell/linux.zsh`, or use `if-shell`/`vim.fn.has` in the config itself.

## Layout

- `.zshrc` — the shell entry point. Loads SSH keys through keychain on Linux (`scripts/ssh_keychain.sh`, before the instant prompt because it may ask for a passphrase), sets `XDG_CONFIG_HOME` on macOS, sources `shell/common.zsh`, then `shell/macos.zsh` or `shell/linux.zsh` by `$OSTYPE`, then `machine/shell.zsh`, then sets up completion, zoxide, fzf and powerlevel10k (instant prompt, theme lookup in the usual install locations, then the shared prompt layout `.p10k.zsh` from this repo, falling back to `~/.p10k.zsh`), and finally sources any files in `$HOME/.config/localenv/` (untracked secrets and overrides, see commit `08ac394`). `.zprofile` only runs Homebrew's shellenv. `~/.zshenv` is not tracked.
- `shell/` — `common.zsh` (history, vi keys, Ctrl-F sessionizer, aliases, PATH for Go/Flutter/Rust/uv, yazi `y` wrapper), `macos.zsh` (Homebrew, MacPorts, jenv), `linux.zsh` (pyenv, Linuxbrew, fnm, MTEX).
- `machines/` — `macbook/`, `i3-4k/` (one 3840x2160 monitor on DP-0 at 143.99 Hz, set by `scripts/i3_autostart.sh`), `i3-hd/` (1080p). Rename the directories freely; nothing refers to them by name except the `machine` symlink.
- `.tmux.conf` — tmux with vi-mode, vim-style pane navigation (`h/j/k/l`), and window-switch bindings on the number keys (`1`–`0` → windows 1–10). The clipboard command is chosen by `if-shell` (pbcopy / xclip), tpm is only loaded when installed. `prefix + f` (and Ctrl-F in zsh) runs `scripts/tmux_sessionizer.sh`: it lists the projects under `project_roots` from `machine/sessionizer.sh`, mounts remote projects with sshfs, and opens `exec`, `edit` (nvim), `git` (lazygit) and `claude` windows.
- `yabai/`, `skhd/` — macOS tiling setup with i3-style keybindings (`alt-j/k/l/;` for focus).
- `i3/`, `polybar/`, `rofi/`, `dunst/`, `picom/` — the Ubuntu i3 stack. Mod key is `Mod4`. `scripts/i3_autostart.sh` sets the display mode before launching the apps (workspace placement comes from `assign` rules in `i3/config`); `$mod+m` toggles a yazi scratchpad. Only the `cuts` polybar theme is used (`i3/config` launches `polybar/launch.sh --cuts`); the other theme directories are upstream material from adi1090x.
- `nvim/` — Neovim config forked from kickstart.nvim, shared by all machines. Entry point is `nvim/init.lua`, which loads:
  - `lua/config/{options,autocmds,keymaps,config}.lua` — editor settings and keymaps
  - `lua/lazy-bootstrap.lua` — installs lazy.nvim on first run
  - `lua/lazy-plugins.lua` — the plugin manifest; each `require` points to a file under `lua/plugins/`
  - `lua/plugins/kickstart/` — upstream kickstart plugin specs (LSP, Telescope, Treesitter, cmp, DAP, etc.)
  - `lua/plugins/custom/` — personal plugin specs (harpoon, oil, neo-tree, obsidian, rose-pine, feline, tmux-navigator, …)
  To add or remove a plugin, edit `lua/lazy-plugins.lua` — it is the single source of truth for what is loaded. Paths inside nvim must stay portable (`vim.fn.expand '~/...'`, `vim.fn.has 'mac'`), not `/Users/...`.
- `alacritty.toml`, `kitty/` — terminal configs (UbuntuMono Nerd Font); size comes from the machine file.
- `yazi/`, `git/ignore`, `scripts/` — shared tools. yazi openers have a Linux and a macOS entry each; `i i`/`i d`/`i p` in yazi run `scripts/image_info.py` and `scripts/image_shell.py`.
- `claude/` — global Claude Code preferences, linked to `~/.claude/` by `./setup`. Not guidance for this repo; that is this file.
- `lazygit/`, `glow/`, `crossnote/`, `uv/`, `swiftpm/`, `homebrew/`, `.android/`, `github-copilot/` — tool state that lands here because `XDG_CONFIG_HOME` points at this repo; all `.gitignore`d.

## Neovim-specific notes

- Leader is `<space>`; `vim.g.have_nerd_font = true` (terminal must render a Nerd Font).
- Custom keymaps in `lua/config/keymaps.lua` remap motion keys: `H→J`, `J→L`, `K→H`, `L→%`, and `kj` in insert mode is `<ESC>`. Keep these in mind when suggesting mappings — don't reintroduce the defaults you're replacing.
- Plugin lockfile is `nvim/lazy-lock.json`. Use `:Lazy sync` inside nvim to update it rather than editing by hand.
- Formatter config lives in `nvim/.stylua.toml` (applies to this repo's Lua).

## Conventions

- Commits here are small and descriptive (`Clean dotfiles`, `Update my neovim config`, `Add localenv for private keys and settings`). Match that tone — no conventional-commit prefixes in this repo's history.
- Secret values go in `$HOME/.config/localenv/`, never inline in tracked files. Non-secret machine differences go in `machines/<name>/`.
