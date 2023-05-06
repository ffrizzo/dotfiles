#!/bin/zsh
echo "\nInstaling Homebrew"
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# Installl homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

eval "$(/opt/homebrew/bin/brew shellenv)"

echo "\nInstaling applications from homebrew"
brew bundle
echo "\nCleanup brew formulas"
brew cleanup --prune=all
