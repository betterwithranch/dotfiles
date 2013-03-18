if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

GIT_VERSION=`git --version | cut -d' ' -f3-`

if [ -f /usr/local/Cellar/git/$GIT_VERSION/etc/bash_completion.d/git-completion.bash ]; then
  source /usr/local/Cellar/git/$GIT_VERSION/etc/bash_completion.d/git-completion.bash 
fi

VIM=~/.vimrc
set -o vi

