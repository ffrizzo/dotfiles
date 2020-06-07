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

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

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