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

echo "\nInstalling Fonts"
open -a Font\ Book ./fonts/*.ttf

echo "\nSetup apps on dock..."
export DOCKUTIL_VERSION=3.0.2
curl -L https://github.com/kcrawford/dockutil/releases/download/${DOCKUTIL_VERSION}/dockutil-${DOCKUTIL_VERSION}.pkg --output dockutil-${DOCKUTIL_VERSION}.pkg
sudo installer -pkg dockutil-${DOCKUTIL_VERSION}.pkg -target /
python3 setup-dock.py
killall Dock
rm -rf dockutil-${DOCKUTIL_VERSION}.pkg
