#!/bin/bash
echo ""
echo "Instaling Homebrew"
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

#installl homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo ""
echo "Instaling applications from homebrew"
#install homebrew-cask
# brew install caskroom/cask/brew-cask

#tap hombrew cask-versions and completions
brew tap homebrew/cask-drivers
brew tap homebrew/cask-versions
brew tap TylerBrock/saw

#install hombrew formulas
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
brew install httpie

brew install awscli
brew install saw
# brew install heroku
brew install packer
brew install terraform
brew install terragrunt
brew install ansible
brew install tree
brew install travis
brew install gitlab-runner

brew install mas
brew install dockutil

# brew cask install dropbox
brew cask install google-backup-and-sync

brew cask install google-chrome-canary
# brew cask install firefox
brew cask install firefox-developer-edition
brew cask install opera-developer
brew cask install tor-browser

brew cask install adobe-acrobat-reader
brew cask install google-hangouts
brew cask install spotify
brew cask install the-unarchiver
brew cask install vlc
brew cask install skype
brew cask install slack
brew cask install keybase
brew cask install harvest

brew cask install java
brew install git-credential-manager

brew cask install virtualbox
# brew cask install vmware-fusion
brew cask install vagrant

brew cask install shiftit
brew cask install iterm2
brew cask install wercker-cli

brew cask install arduino
# brew cask install atom
brew cask install intellij-idea-ce
# brew cask install pycharm-ce
brew cask install visual-studio-code
brew cask install paw

brew cask install sourcetree
brew cask install diffmerge

brew cask install studio-3t
# brew cask install pgadmin4
# brew cask install mysqlworkbench

IS_LAPTOP=`/usr/sbin/system_profiler SPHardwareDataType | grep "Model Identifier" | grep "Book"`
if [[ "$IS_LAPTOP" != "" ]]; then
  brew cask install chronoagent
else
  brew cask install chronosync
  brew cask install logitech-gaming-software
  brew cask install steelseries-engine
fi

#install docker mac app
brew cask install docker
#install docker-machine xhyve driver
# brew install docker-machine-driver-xhyve

brew install xhyve

brew install kubernetes-cli
brew install kubernetes-helm
brew install kubectl
brew install kubectx
brew install kops

brew cask install minikube

#install homebrew completions
brew install bash-completion
brew install vagrant-completion

echo ""
echo "Cleanup brew formulas"
brew cleanup
