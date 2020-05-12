export EDITOR='code'

export NVM_DIR=$HOME/.nvm
source $(brew --prefix nvm)/nvm.sh

export PYENV_ROOT=$HOME/.pyenv
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

export GO111MODULE=on
export GOPATH=$HOME/workspaces/go/
export PATH=$PATH:$GOPATH/bin

export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

