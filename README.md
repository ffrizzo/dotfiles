# Fabiano's dotfiles
This repository include all of my custom dotfiles.

This include the following step.
  * install xcode-cli
  * install homebrew
  * install all applications from homebrew
  * install VS Code / Cursor extensions
  * install external softwares
  * run set OsX system defaults
  * run set user defaults
  * copy configurations to home user folder
  * install latest updates from app store
  * configure Dock with the applications

## Installation

This is a two-repo setup. This repo covers everything public (Homebrew packages, shell config, macOS defaults, Dock). A second, private repo — `dotfiles-confidential` — covers 1Password, SSH, and work-specific tools, and needs to be run separately.

### 1. This repo

```bash
mkdir dotfiles
cd dotfiles
curl -#L http://github.com/ffrizzo/dotfiles/tarball/master | tar -xvz --strip-components 1
chmod +x *.sh
sh setup.sh
cd ..
rm -rf dotfiles
```

A couple of things `brew bundle` can't do for you, run once after `setup.sh` finishes:
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

### Keeping tracked dotfiles in sync

`setup.sh` copies `./home/` into `~/` (not symlinked), so local edits to files like `.zshrc` don't automatically flow back into the repo. Run `sh sync-from-home.sh` before committing to pull your current `~/.zshrc`, `~/.zprofile`, etc. back into `./home/`.
