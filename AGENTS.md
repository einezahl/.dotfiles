# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Personal dotfiles for a Linux + i3 + tmux + Neovim workstation. The repo is meant to be cloned to `~/.dotfiles` (this path is hard-coded in `.tmux.conf`, `i3/config`, and `.bash_profile`). Configs are activated by symlinking from this directory into `$XDG_CONFIG_HOME` and `$HOME`.

## Setup commands

- `./install.sh` — apt-installs system packages (i3, tmux, polybar, picom, rofi, dunst, ripgrep, lazygit, npm), downloads the Neovim AppImage to `/usr/local/bin/nvim`, and installs `black`, `uv`, `ast-grep-cli` via pipx. Run once on a fresh machine.
- `./setup.sh` — backs up any existing configs to `$XDG_CONFIG_HOME/old_config/` and creates symlinks from this repo into `$XDG_CONFIG_HOME` (`kitty/`, `alacritty/`, `nvim/`, `dunst/`, `i3/`, `picom/`, `polybar/`, `rofi/`) and `$HOME` (`.bash_profile`, `.bashrc`, `.tmux.conf`). **Must be run from the repo root** — it uses `$PWD` to compute symlink targets.

Note: `.bash_profile` overrides `XDG_CONFIG_HOME` to `$HOME/.dotfiles` itself, so on this machine "config dir" effectively means this repo.

## Architecture

### Symlink layout

Every top-level dir/file that `setup.sh` references is a deployed config. Edits in this repo take effect immediately for the running tools (the symlink points back here). When adding a new tool's config, add both an `unlink` cleanup line AND an `ln -sf` line to `setup.sh` — the script is the source of truth for what gets deployed.

### Neovim (`nvim/`)

Built on top of [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim). Entry point is `nvim/init.lua`, which loads:

1. `lua/config/{options,autocmds,keymaps}.lua` — base editor settings.
2. `lua/lazy-bootstrap.lua` → `lua/lazy-plugins.lua` — lazy.nvim plugin manager + the plugin spec list.
3. `lua/config/config.lua` — post-plugin setup.

Plugin specs are split into two folders:
- `lua/plugins/kickstart/` — upstream kickstart plugins (LSP, telescope, treesitter, cmp, dap, gitsigns, etc.). Treat as vendor-ish; modify with care.
- `lua/plugins/custom/` — user additions (harpoon, oil, neo-tree, rosepine, undotree, luasnip, lsp_signature, vim-tmux-navigator, ...).

To enable/disable a plugin, comment/uncomment its `require` line in `lua/lazy-plugins.lua` (this is the existing pattern — many entries there are already commented out).

### tmux + project sessionizer

`scripts/tmux_sessionizer.sh` (bound to `prefix + f` in `.tmux.conf`) is the project switcher:

- Discovers local projects with `find $HOME/dev/ -mindepth 3 -maxdepth 3 -type d` (i.e. expects projects nested at `~/dev/<group>/<category>/<project>`).
- Has a hard-coded `remote_projects` array for HPC entries (currently one: `hpcwork-kair`). Format: `name|remote_path|ssh_host`. The script auto-mounts the remote path via `sshfs` to `$HOME/cluster/<name>`.
- Creates a 3-window tmux session per project: `exec`, `edit` (opens nvim), `git` (opens lazygit). All windows source `.venv/bin/activate` and prepend the project to `PYTHONPATH`.

To add a new HPC project, append a `name|path|ssh_host` line to the `remote_projects` array in this script.

### i3 + polybar + rofi

- `i3/config` — Mod key is `Mod4` (Super). Single-monitor 4K@144 setup wired with explicit `xrandr` lines at the top. Custom bindings worth knowing: `Mod+Shift+a` runs `scripts/add_anki_card.sh` (uses AnkiConnect on `localhost:8765`); `Mod+i` runs `i3/lockscreen.sh`; `Mod+o` re-launches polybar.
- `polybar/launch.sh` is theme-switchable: each top-level dir under `polybar/` (`cuts`, `hack`, `material`, `shades`, ...) is a self-contained theme. The active theme is selected by the flag in `i3/config` (currently `--cuts`). Edit `polybar/cuts/` for the live bar; ignore the other theme dirs unless switching.
- `rofi/main.rasi` is the active theme; `full_screen.rasi` and `main_without_icons.rasi` are alternatives referenced from `i3/config` for different launchers.

## Conventions specific to this repo

- The repo path `~/.dotfiles` is hard-coded in several configs — don't refactor to a variable without updating all call sites (`.tmux.conf:49`, `i3/config:127`, etc.).
- `i3/config.save*` are i3's own backup files from `Mod+Shift+c` reloads — leave them alone, they're not edited by hand.
- `.gitignore` excludes `*lock.json`, `lazyvim.json`, and several `$XDG_CONFIG_HOME` subdirs (`.android/`, `Google/`, `lazygit/`, `crossnote/`) that exist here only because `XDG_CONFIG_HOME` points at this repo.
- When `setup.sh` runs it moves *existing* non-symlink configs to `$XDG_CONFIG_HOME/old_config/`. If asked to re-run setup, warn the user about this — old configs there are one layer of backup deep, not preserved across multiple runs.
