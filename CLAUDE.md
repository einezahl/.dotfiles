# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Personal dotfiles for a Linux (i3) + occasional macOS setup. This repo is the source of truth — `$XDG_CONFIG_HOME` is pointed at `~/.dotfiles` (see `.bash_profile`), and application configs are consumed in-place or via symlinks created by `setup.sh`.

## Setup

- `./install.sh` — installs system packages (i3, dunst, polybar, picom, rofi, pyenv). Debian/Ubuntu only.
- `./setup.sh` — symlinks configs into `$XDG_CONFIG_HOME` and `$HOME`. Existing files are moved to `$XDG_CONFIG_HOME/old_config` first. Must be run from the repo root (uses `$PWD`).

Neovim bootstraps itself via lazy.nvim on first launch (`nvim/lua/lazy-bootstrap.lua`); there is no separate install step for plugins.

## Architecture

### Two layers of config delivery

1. **Symlinked** (via `setup.sh`): `alacritty.toml`, `.bash_profile`, `.bashrc`, `.tmux.conf`, and the `nvim/`, `dunst/`, `i3/`, `picom/`, `polybar/`, `rofi/` directories.
2. **Read in-place**: because `.bash_profile` sets `XDG_CONFIG_HOME="$HOME"/.dotfiles`, apps that honor XDG (nvim, etc.) read directly from this repo even without symlinks. Keep this dual-path behavior in mind — changes here affect the live environment immediately when XDG is honored, but require re-running `setup.sh` for the symlink-only targets.

### Neovim (`nvim/`)

Built on **kickstart.nvim**. Entry point `init.lua` loads, in order:
`config.options` → `config.autocmds` → `config.keymaps` → `lazy-bootstrap` → `lazy-plugins` → `config.config`.

- `lua/config/` — editor options, autocmds, keymaps, and post-plugin config.
- `lua/plugins/kickstart/` — upstream kickstart plugin specs (LSP, Treesitter, Telescope, cmp, dap, etc.). Avoid diverging from kickstart's patterns here unless necessary.
- `lua/plugins/custom/` — user-added plugin specs. Enable/disable by editing the `require` list in `lua/lazy-plugins.lua` (commented-out entries are intentional — preserve them when editing).

Leader is `<space>`. Notable custom keymaps live in `lua/config/keymaps.lua` (e.g. `kj` for escape, `J`/`K` remapped to scroll, `<C-x>` runs the current file with python, `<Tab>` toggles last buffer via `ToggleBuffers()`).

### tmux sessionizer (`scripts/tmux_sessionizer.sh`)

Bound to `<prefix>f` in `.tmux.conf`. `fzf`s over hardcoded project roots under `/home/admd/dev/...` and spawns a 3-window session (`exec`, `edit`, `git`) with `.venv` activation and `PYTHONPATH` set. When adding/removing project roots, edit the `find` invocation at the top of the script.

### Shell (`.bashrc`, `.bash_profile`)

`.bash_profile` is macOS-aware (sources Homebrew shellenv only on Darwin) and sets `XDG_CONFIG_HOME` before sourcing `.bashrc`. `.bashrc` short-circuits for non-interactive shells — anything needed by scripts must go in `.bash_profile` or be exported elsewhere.

### i3 (`i3/config`)

Based on a Keyitdev template. Launches picom, mpd, dunst, feh (wallpaper), `set_keyboard.sh`, and `polybar/launch.sh --cuts` at startup. `config.save*` files are i3's auto-backups from `i3-config-wizard` — do not treat them as active.

### Polybar (`polybar/`)

Multiple themes as sibling directories (`cuts`, `blocks`, `forest`, etc.). `launch.sh` selects which theme to start; i3 currently launches with `--cuts`.

## Conventions

- This is a single-user personal repo — no tests, no CI, no build step. "Run the thing and see if it works" is the validation loop.
- When adding a new app config, decide whether it belongs under XDG (drop a directory in the repo root, no symlink needed) or needs a symlink (add to both the cleanup and `ln -sf` blocks of `setup.sh`).
- `.gitignore` excludes `*lock.json`, `lazyvim.json`, logs, and several app subdirectories that contain machine-specific state (`Google/`, `.android/`, `crossnote/`, etc.). Prefer adding to `.gitignore` over committing machine-local noise.
