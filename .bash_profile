# .bash_profile
# configure multi-line prompt
PS1='
\[\e[36;1m\]\u @ \[\e[32;1m\]\w > \[\e[0m\]
==> '

# History Tweaks
HISTCONTROL=ignoredups:ignorespace
HISTSIZE=1000
HISTFILESIZE=2000

# colours!
export GREP_OPTIONS="--color=auto"
export GREP_COLOR="4;33"
export CLICOLOR="auto"
export LSCOLORS=GxFxCxDxBxegedabagaced

#completion's
if [ -f $(brew --prefix)/etc/bash_completion ]; then
   . $(brew --prefix)/etc/bash_completion
fi

# git prompt
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWUPSTREAM=auto
export GIT_PS1_SHOWSTASHSTATE=true

export EDITOR='open -a /Applications/Atom.app'

#alias
alias ll='ls -la'
alias cd..='cd ..'
alias home='cd ~'

alias gitf=git-flow
