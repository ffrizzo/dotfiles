# Fabiano's dotfiles

Managed with [chezmoi](https://www.chezmoi.io). Covers Homebrew packages, shell config, macOS defaults, Dock, and editor extensions (VS Code + Cursor).

## Installation

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ffrizzo/dotfiles
```

This installs chezmoi, clones this repo, and applies everything: Xcode CLI tools, Homebrew plus every package in `Brewfile`, zinit (zsh plugin manager), macOS system/user defaults, fonts, browser extension stubs, Dock layout, and VS Code/Cursor extensions. See `.chezmoiscripts/` for exactly what runs and in what order.

A couple of things `chezmoi apply` can't do for you, run once afterward:

- `rustup default stable` — finishes the Rust toolchain setup.
- `mise install` — installs the Terraform versions pinned in `dot_config/mise/config.toml`
- Browser bookmarks and other home-only state — back them up and restore them with `home-state.sh` below. `chezmoi apply` installs that script as `~/scripts/home-state.sh`.

## Day-to-day usage

- `chezmoi edit ~/.zshrc` — edit a managed file (opens the source file, e.g. `dot_zshrc`).
- `chezmoi diff` — preview what `chezmoi apply` would change before changing anything.
- `chezmoi apply` — apply the source state to `$HOME`.
- `chezmoi re-add` — pull a file you edited directly (e.g. `~/.zshrc`) back into the source state, so it's ready to commit.
- `chezmoi cd` — cd into the source directory to commit/push changes.

## Bookmarks and other home state

`chezmoi apply` can reinstall packages and rewrite dotfiles. It cannot recreate browser bookmarks or anything else that only exists under your home directory. `scripts/home-state.manifest` lists those paths. Add a `file` or `dir` line there for anything else you want carried to a new machine.

```bash
# From this repo, or ~/scripts/home-state.sh after chezmoi apply:
scripts/executable_home-state.sh backup /Volumes/Backup/home-state
scripts/executable_home-state.sh restore /Volumes/Backup/home-state
```

`backup` replaces the snapshot in that folder. Pass a different folder to keep an older copy. Quit the apps before `restore`. Firefox stores bookmarks in `places.sqlite`, which also contains browsing history, so that file is part of the snapshot. Reading Safari bookmarks needs Full Disk Access for the terminal app running the script.

VS Code and Cursor `settings.json`, `keybindings.json`, and extensions already come back from `chezmoi apply`. The manifest adds the configs that do not: MCP servers, Cursor launch flags and CLI preferences, Claude Code settings, and the Claude desktop MCP config. Sign in to Claude again on the new Mac. The login files also contain a machine id, so they are left out.

## Structure

- `Brewfile` — Homebrew formulae, casks, and VS Code extensions, installed via `brew bundle`.
- `.chezmoiscripts/` — install/setup scripts, run in order by `chezmoi apply` (numeric prefix = order; `run_once_` = once ever per machine; `run_onchange_` = re-runs when its own rendered content changes, e.g. the Brewfile install and Cursor extension scripts re-run whenever `Brewfile` changes). macOS defaults and the Dock layout re-run when the macOS version changes.
- `dot_*` — dotfiles, applied to `$HOME` (e.g. `dot_zshrc` → `~/.zshrc`; `dot_config/mise/config.toml` → `~/.config/mise/config.toml`; `dot_warp/settings.toml` → `~/.warp/settings.toml`).
- `Library/` — editor settings applied under `~/Library` (VS Code and Cursor). Warp's preference plist and iTerm2 are unmanaged.
- `fonts/` — bundled fonts, installed by `.chezmoiscripts/run_once_after_23-fonts.sh.tmpl`.
- `scripts/` — `executable_home-state.sh` and `home-state.manifest`. `chezmoi apply` installs them as `~/scripts/home-state.sh` and `~/scripts/home-state.manifest`.

## Maintenance

After editing `Brewfile`, run `brew bundle check --verbose --no-upgrade --file=Brewfile` locally to catch renamed/removed formulas and casks before committing — CI only checks that the file parses, not that every entry still resolves (see the comment in `run_onchange_before_10-packages.sh.tmpl` for why).
