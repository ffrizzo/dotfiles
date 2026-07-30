#!/bin/zsh
echo "\nSetup OsX..."

sh install-cli-tools.sh

sh install-homebrew.sh
sh install-broswer-extensions.sh

sudo sh osx-system-defaults.sh
sh osx-user-defaults.sh

mkdir -p ~/.pyenv

sudo ln -sf $(brew --prefix bash)/bin/bash /usr/local/bin/bash

echo "\nInstalling Fonts"
open -a Font\ Book ./fonts/*.ttf

sh setup-dock.sh

sh install-zsh.sh
yes | cp -a ./home/ ~/

echo "\nInstalling Brewfile's VS Code extensions on Cursor..."
sh install-cursor-plugins.sh

echo "\n=================================================="
echo "Almost done. A couple of things brew bundle can't do for you:"
echo "  - run 'rustup default stable' once to finish the Rust toolchain setup"
echo "  - run 'mise install' once to pick up the pinned terraform versions"
echo "  - clone and run the dotfiles-confidential repo for 1Password/SSH/work tools:"
echo "      git clone git@github.com:ffrizzo/dotfiles-confidential.git"
echo "      cd dotfiles-confidential && sh setup.sh"
echo "=================================================="
