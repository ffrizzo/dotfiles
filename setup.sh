#!/bin/zsh
echo "\nSetup OsX..."

sh install-cli-tools.sh

sh install-homebrew.sh
sh install-tools.sh
sh install-vscode-plugins.sh

sudo sh osx-system-defaults.sh
sh osx-user-defaults.sh

mkdir -p ~/.pyenv

sudo ln -sf $(brew --prefix bash)/bin/bash /usr/local/bin/bash

echo "\nInstalling Fonts"
open -a Font\ Book ./fonts/*.ttf

sh setup-dock.sh

sh install-zsh.sh
yes | cp -a ./home/ ~/
