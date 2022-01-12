#!/bin/zsh
echo "\nInstalling latest CLI Tools..."
xcode-select --install

echo "\nSoftware Update..."
softwareupdate -ia --verbose