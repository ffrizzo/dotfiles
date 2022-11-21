eval "$(/opt/homebrew/bin/brew shellenv)"

export EDITOR='code'

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

export NVM_DIR=$HOME/.nvm
source $(brew --prefix nvm)/nvm.sh

eval "$(jump shell)"

export GO111MODULE=on
export GOPATH=$HOME/workspaces/go/
export PATH=$PATH:$GOPATH/bin

export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi

alias st='open -a SourceTree'

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/bin:$PATH"
