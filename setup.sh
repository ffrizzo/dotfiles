echo
echo "Setup OsX"

sh install-cli-tools.sh
sh install-homebrew.sh
sh install-atom-plugins.sh
sh install external-software.sh

sh osx-system-defaults.sh
sh osx-user-defaults.sh

cp .bash_profile ~/
cp .gitconfig ~/
cp .gitignore_global ~/

echo
echo "Software Update"
softwareupdate -iva
