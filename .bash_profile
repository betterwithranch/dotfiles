if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

if [ -f /usr/local/Cellar/git/1.7.3.2/etc/bash_completion.d/git-completion.bash ]; then
  source /usr/local/Cellar/git/1.7.3.2/etc/bash_completion.d/git-completion.bash 
fi

VIM=~/.vimrc
set -o vi

