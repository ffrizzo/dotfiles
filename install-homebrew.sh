#!/bin/zsh
printf "\nInstaling Homebrew\n"
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

#installl homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

printf "\nInstaling applications from homebrew\n"

brew tap homebrew/bundle
brew bundle

printf "\nCleanup brew formulas\n"
brew cleanup
