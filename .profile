export EDITOR='code'

export NVM_DIR=$HOME/.nvm
source $(brew --prefix nvm)/nvm.sh

export PYENV_ROOT=$HOME/.pyenv
export PATH="$PYENV_ROOT/bin:$PATH"

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
eval "$(jump shell)"

export GO111MODULE=on
export GOPATH=$HOME/workspaces/go/
export PATH=$PATH:$GOPATH/bin

export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

export PATH="$HOME/.cargo/bin:$PATH"
export PATH=/Applications/VMware\ OVF\ Tool/:$PATH

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi

# Terraform version
load-tfswitch() {
  local tfswitchrc_path=".tfswitchrc"

  if [ -f "$tfswitchrc_path" ]; then
    tfswitch
    terraform -install-autocomplete
  fi
}
add-zsh-hook chpwd load-tfswitch
load-tfswitch

# Terragrunt version
load-tgswitch() {
  local tgswitchrc_path=".tgswitchrc"

  if [ -f "$tgswitchrc_path" ]; then
    tgswitch
  fi
}
add-zsh-hook chpwd load-tgswitch
load-tgswitch

