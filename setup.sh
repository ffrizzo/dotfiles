#!/bin/zsh
printf "\nSetup OsX...\n"

sh install-cli-tools.sh

printf "\nSoftware Update...\n"
softwareupdate -ia --verbose

sh install-homebrew.sh
sh install-vscode-plugins.sh
sh install-tools.sh

sudo sh osx-system-defaults.sh
sh osx-user-defaults.sh

cp .profile ~/
cp .aliases ~/
cp .kubectl-aliases ~/
cp .zshrc ~/
cp .inputrc ~/
cp .gitconfig ~/
cp .gitignore-global ~/
cp .p10k.zsh ~/
cp -r .git-templates ~/.git-templates

yes | cp -rf ./Library/Preferences/* ~/Library/Preferences
yes | cp -rf ./Library/Application\ Support/* ~/Library/Application\ Support

printf "\nSetup apps on dock...\n"
python setup-dock.py
killall Dock

mkdir -p ~/.nvm
mkdir -p ~/.pyenv

sh install-zsh.sh      