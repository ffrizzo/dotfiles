#!/bin/zsh
echo "\nInstall oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

compaudit | xargs chmod g-w,o-w
