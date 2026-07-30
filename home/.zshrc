# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="agnoster"

ZSH_DOTENV_PROMPT=Always

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  aliases
  ansible
  aws
  branch
  brew
  cp
  docker
  docker-compose
  dotenv
  gcloud
  gem
  git
  git-extras
  git-flow
  golang
  helm
  history
  iterm2
  jira
  kops
  kubectl
  minikube
  node
  npm
  macos
  pip
  pipenv
  postgres
  pyenv
  python
  redis-cli
  rust
  terraform
  vagrant
  virtualenv
  vscode
  yarn

  # zsh-autosuggestions
  # zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

autoload -U +X bashcompinit && bashcompinit

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export GPG_TTY=$(tty)

eval "$(mise activate zsh)"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/ffrizzo/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
