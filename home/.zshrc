# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="agnoster"
# ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  ansible
  aws
  branch
  brew
  celery
  cp
  docker
  docker-compose
  gcloud
  gem
  git
  git-extras
  git-flow
  golang
  helm
  history
  httpie
  iterm2
  jira
  kops
  kubectl
  minikube
  node
  npm
  nvm
  macos
  pip
  pipenv
  postgres
  pyenv
  python
  redis-cli
  terraform
  vagrant
  vault
  virtualenv
  vscode
  xcode
  yarn
)

source $ZSH/oh-my-zsh.sh
source $HOME/.kubectl-aliases


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

# Terraform version
load-tfswitch() {
  local tfswitchrc_path=".tfswitchrc"

  if [ -f "$tfswitchrc_path" ]; then
    tfswitch
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

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f $(HOME)/.nvm/versions/node/v8.2.1/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh ]] && . $(HOME)/.nvm/versions/node/v8.2.1/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f $(HOME)/.nvm/versions/node/v8.2.1/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh ]] && . $(HOME)/.nvm/versions/node/v8.2.1/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh

source $(brew --prefix)/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/opt/powerlevel10k/powerlevel10k.zsh-theme