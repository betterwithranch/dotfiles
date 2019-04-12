if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

export JAVA_HOME=$(/usr/libexec/java_home)

GIT_VERSION=`git --version | cut -d' ' -f3-`

if [ -f /usr/local/Cellar/git/$GIT_VERSION/etc/bash_completion.d/git-completion.bash ]; then
  source /usr/local/Cellar/git/$GIT_VERSION/etc/bash_completion.d/git-completion.bash 
fi

eval "$(rbenv init -)"

export NVM_DIR="$HOME/.nvm"
. "$(brew --prefix nvm)/nvm.sh"

export PATH="/usr/local/opt/openssl/bin:$PATH"
eval "$(direnv hook bash)"
