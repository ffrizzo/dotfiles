#!/bin/zsh
echo "\nSetup OsX..."

sh install-cli-tools.sh

sh install-homebrew.sh
sh install-tools.sh
sh install-vscode-plugins.sh

sudo sh osx-system-defaults.sh
sh osx-user-defaults.sh

yes | cp -a ./home/ ~/

mkdir -p ~/.nvm
mkdir -p ~/.pyenv

sh install-zsh.sh      

echo "\nSetup apps on dock..."
python setup-dock.py
killall Dock