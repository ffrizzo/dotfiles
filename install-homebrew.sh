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
brew tap caskroom/versions
brew tap homebrew/completions

#install hombrew formulas
brew install dos2unix
brew install git
brew install mercurial
brew install wget
brew install go
brew install pyenv
brew install pyenv-virtualenv

brew install awscli
brew install awslogs
brew install heroku
brew install terraform
brew install packer
brew install ansible
brew install tree
brew install travis
brew install wercker-cli

brew install dockutil

# brew cask install dropbox
brew cask install google-backup-and-sync

brew cask install google-chrome-canary
# brew cask install firefox
brew cask install firefox-developer-edition
brew cask install opera-developer
brew cask install torbrowser

brew cask install adobe-acrobat-reader
brew cask install google-hangouts
brew cask install spotify
brew cask install the-unarchiver
brew cask install vlc
brew cask install skype
brew cask install slack-beta
brew cask install keybase
brew cask install harvest

brew cask install java
brew install git-credential-manager

brew cask install virtualbox
# brew cask install vmware-fusion
brew cask install vagrant

brew cask install shiftit
brew cask install iterm2

brew cask install arduino
brew cask install atom
brew cask install intellij-idea-ce
brew cask install pycharm-ce
brew cask install visual-studio-code
brew cask install paw

brew cask install sourcetree
brew cask install diffmerge

brew cask install studio-3t
brew cask install pgadmin4
# brew cask install mysqlworkbench

IS_LAPTOP=`/usr/sbin/system_profiler SPHardwareDataType | grep "Model Identifier" | grep "Book"`
if [[ "$IS_LAPTOP" != "" ]]; then
  brew cask install chronoagent
else
  brew cask install chronosync
  brew cask install logitech-gaming-software
  brew cask install steelseries-engine
fi

#install homebrew completions
brew install bash-completion
brew install vagrant-completion

#install docker mac app
brew cask install docker
#install docker-machine xhyve driver
brew install docker-machine-driver-xhyve

echo ""
echo "Cleanup brew formulas"
brew cleanup
brew cask cleanup
