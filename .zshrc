eval "$(/opt/homebrew/bin/brew shellenv)"
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

if [ -f /usr/local/Cellar/git/$GIT_VERSION/etc/bash_completion.d/git-completion.bash ]; then
  source /usr/local/Cellar/git/$GIT_VERSION/etc/bash_completion.d/git-completion.bash 
fi

. $(brew --prefix asdf)/asdf.sh

export WORKON_HOME=~/.virtualenvs
. $(asdf where python)/bin/virtualenvwrapper.sh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/craig.israel/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/craig.israel/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/craig.israel/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/craig.israel/google-cloud-sdk/completion.zsh.inc'; fi

autoload -U edit-command-line
bindkey -M vicmd v edit-command-line
