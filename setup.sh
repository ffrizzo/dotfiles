#!/bin/zsh
echo "\nSetup OsX..."

sh install-cli-tools.sh

sh install-homebrew.sh
sh install-tools.sh
sh install-vscode-plugins.sh

sudo sh osx-system-defaults.sh
sh osx-user-defaults.sh

mkdir -p ~/.nvm
mkdir -p ~/.pyenv

echo "\nInstalling Fonts"
open -a Font\ Book ./fonts/*.ttf

echo "\nSetup apps on dock..."
DOCKUTIL_LOCATION=$(curl -s https://api.github.com/repos/kcrawford/dockutil/releases/latest \
| grep "browser_download_url" \
| awk '{ print $2 }' \
| sed 's/,$//'       \
| sed 's/"//g' )
curl -L ${DOCKUTIL_LOCATION} -o dockutil.pkg
sudo installer -pkg dockutil.pkg -target /
python3 setup-dock.py
killall Dock
rm -rf dockutil-${DOCKUTIL_VERSION}.pkg

sh install-zsh.sh
yes | cp -a ./home/ ~/
