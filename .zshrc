if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
export PATH="$PATH:$(yarn global bin)"
export EDITOR=vim
alias mux=tmuxinator
alias dbm="bundle exec rails db:migrate"
alias s="bundle exec rspec spec"
set -o vi

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

. $(brew --prefix asdf)/asdf.sh

if [ -f $(asdf where python)/bin/virtualenvwrapper.sh ]; then
  export WORKON_HOME=~/.virtualenvs
  . $(asdf where python)/bin/virtualenvwrapper.sh
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/craig.israel/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/craig.israel/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/craig.israel/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/craig.israel/google-cloud-sdk/completion.zsh.inc'; fi

autoload -U edit-command-line
bindkey -M vicmd v edit-command-line
