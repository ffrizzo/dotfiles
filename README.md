# Fabiano's dotfiles

Managed with [chezmoi](https://www.chezmoi.io). Covers Homebrew packages, shell config, macOS defaults, Dock, and editor extensions (VS Code + Cursor).

This is a two-repo setup. This repo covers everything public. A second, private repo — `dotfiles-confidential` — covers 1Password, SSH, and work-specific tools, and is run separately (see below).

## Installation

### 1. This repo

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ffrizzo/dotfiles
```

This installs chezmoi, clones this repo, and applies everything: Xcode CLI tools, Homebrew plus every package in `Brewfile`, oh-my-zsh, macOS system/user defaults, fonts, browser extension stubs, Dock layout, and VS Code/Cursor extensions. See `.chezmoiscripts/` for exactly what runs and in what order.

A couple of things `chezmoi apply` can't do for you, run once afterward:
- `rustup default stable` — finishes the Rust toolchain setup.
- `mise install` — installs the pinned runtime versions (e.g. Terraform) that `mise` manages.

### 2. dotfiles-confidential

```bash
git clone git@github.com:ffrizzo/dotfiles-confidential.git
cd dotfiles-confidential
chmod +x *.sh
sh setup.sh
cd ..
rm -rf dotfiles-confidential
```

## Day-to-day usage

- `chezmoi edit ~/.zshrc` — edit a managed file (opens the source file, e.g. `dot_zshrc`).
- `chezmoi diff` — preview what `chezmoi apply` would change before changing anything.
- `chezmoi apply` — apply the source state to `$HOME`.
- `chezmoi re-add` — pull a file you edited directly (e.g. `~/.zshrc`) back into the source state, so it's ready to commit.
- `chezmoi cd` — cd into the source directory to commit/push changes.

## Structure

- `Brewfile` — Homebrew formulae, casks, and VS Code extensions, installed via `brew bundle`.
- `.chezmoiscripts/` — install/setup scripts, run in order by `chezmoi apply` (numeric prefix = order; `run_once_` = once ever per machine; `run_onchange_` = re-runs when its own rendered content changes, e.g. the Brewfile install script re-runs whenever `Brewfile` changes).
- `dot_*` — dotfiles, applied to `$HOME` (e.g. `dot_zshrc` → `~/.zshrc`).
- `Library/` — app preferences/settings applied under `~/Library` (VS Code, iTerm2, Warp).
- `fonts/` — bundled fonts, installed by `.chezmoiscripts/run_once_after_23-fonts.sh.tmpl`.
