#!/bin/zsh
printf "\nSetup OsX...\n"

sh install-cli-tools.sh

printf "\nSoftware Update...\n"
softwareupdate -ia --verbose

sh install-homebrew.sh
sh install-vscode-plugins.sh
sh install-mass-apps.sh

sh install-zsh.sh       

sudo sh osx-system-defaults.sh
sh osx-user-defaults.sh

cp .profile ~/
cp .alias ~/
cp .zshrc ~/
cp .inputrc ~/
cp .gitconfig ~/
cp .gitignore_global ~/
cp -r .git-templates ~/.git-templates

yes | cp -rf ./Library/Preferences/* ~/Library/Preferences

printf "\nSetup apps on dock...\n"
python setup-dock.py
killall Dock

cp vscode-settings.json ~/Library/Application\ Support/Code/User/settings.json
cp vscode-keybidings.json ~/Library/Application\ Support/Code/User/keybindings.json

terraform -install-autocomplete