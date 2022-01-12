#!/bin/zsh
echo "\nInstalling latest CLI Tools..."
xcode-select --install

echo "\nSoftware Update..."
softwareupdate -ia --verbose

if [[ $(uname -m) == 'arm64' ]]; then
    echo "\nInstalling Roseta..."
    sudo softwareupdate --install-rosetta
fi