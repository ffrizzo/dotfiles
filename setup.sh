#!/bin/zsh
echo ""
echo "Setup OsX"

sh install-cli-tools.sh

echo ""
echo "Software Update"
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

echo ""
echo "Setup apps on dock"
python setup-dock.py
killall Dock

cp vscode-settings.json ~/Library/Application\ Support/Code/User/settings.json
cp vscode-keybidings.json ~/Library/Application\ Support/Code/User/keybindings.json

terraform -install-autocomplete