export PATH="$PATH:$(yarn global bin)"
export EDITOR=vim

# For Apple Silicon
export DOCKER_DEFAULT_PLATFORM=linux/amd64

alias mux=tmuxinator
alias dbm="bundle exec rails db:migrate"
alias s="bundle exec rspec spec"
alias vim=nvim

installOhMyZsh() {
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

GIT_VERSION=`git --version | cut -d' ' -f3-`

# configure git completion in bash
# if [ -f /usr/local/Cellar/git/$GIT_VERSION/etc/bash_completion.d/git-completion.bash ]; then
#  source /usr/local/Cellar/git/$GIT_VERSION/etc/bash_completion.d/git-completion.bash 
# fi

# configure git completion in zsh
#zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
#fpath=(~/.zsh $fpath)
#autoload -Uz compinit && compinit


# Zsh plugins
plugins=(git docker docker-compose rails ruby)
source $ZSH/oh-my-zsh.sh

if [ -f $(asdf where python)/bin/virtualenvwrapper.sh ]; then
  export WORKON_HOME=~/dev/python
  . $(asdf where python)/bin/virtualenvwrapper.sh
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/craig.israel/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/craig.israel/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/craig.israel/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/craig.israel/google-cloud-sdk/completion.zsh.inc'; fi

autoload -U edit-command-line
bindkey -M vicmd v edit-command-line
set -o vi
