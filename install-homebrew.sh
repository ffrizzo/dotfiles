#!/bin/bash
echo ""
echo "Instaling Homebrew"
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

#installl homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo ""
echo "Instaling applications from homebrew"

#tap hombrew cask-versions and completions
brew tap homebrew/cask-drivers
brew tap homebrew/cask-versions

#install hombrew formulas
brew install gettext
brew install fd
brew install jq
brew install yq
brew install yamllint
brew install dos2unix
brew install git
brew install mercurial
brew install wget
brew install go
brew install pyenv
brew install pyenv-virtualenv
brew install nvm
brew install yarn
brew install httpie
brew install hugo
brew install trash
brew install upx

brew install golangci/tap/golangci-lint
brew install goreleaser/tap/goreleaser

brew install awscli
brew install TylerBrock/saw
brew install packer
brew install ansible
brew install tree
brew install travis
brew install gitlab-runner

brew install warrensbox/tap/tfswitch
brew install warrensbox/tap/tgswitch

brew install mas
brew install dockutil

brew cask install authy

brew cask install google-chrome-canary
brew cask install firefox-developer-edition
brew cask install opera-developer
brew cask install tor-browser
brew cask install brave-browser
brew cask install transmission

brew cask install google-hangouts
brew cask install spotify
brew cask install the-unarchiver
brew cask install vlc
brew cask install skype
brew cask install slack-beta
brew cask install keybase
brew cask install harvest
brew cask install blue-jeans

brew cask install java
brew install git-credential-manager

brew cask install shiftit
brew cask install iterm2

brew cask install balenaetcher
brew cask install arduino
brew cask install visual-studio-code
brew cask install paw

brew cask install sourcetree
brew cask install diffmerge

brew install kubernetes-cli
brew install helm
brew install kubectl
brew install kubectx
brew install kops
brew install k3d

brew cask install docker
brew cask install minikube

#install homebrew completions
brew install bash-completion

echo ""
echo "Cleanup brew formulas"
brew cleanup
