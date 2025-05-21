export PATH="/usr/local/opt/openssl/bin:$PATH"
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/local/sbin:$PATH"

export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_BUNDLE_FILE=~/Brewfile
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

installOhMyZsh() {
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}


# For Apple Silicon
export DOCKER_DEFAULT_PLATFORM=linux/amd64

alias cdk="npx cdk"
alias mux=tmuxinator
alias dbm="bundle exec rails db:migrate"
alias s="bundle exec rspec spec"
alias vim=nvim
alias tmux="TERM=screen-256color-bce tmux"
alias mux="tmuxinator"
alias rspec="bundle exec rspec"

alias pips="pipenv shell"
alias pm="python manage.py"
alias psh="python manage.py shell"
# requires django-extensions
alias pshp="python manage.py shell_plus"

# dotfile repo
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

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
plugins=(aws asdf direnv docker docker-compose git pipenv rails ruby)
source $ZSH/oh-my-zsh.sh

export PATH="$PATH:$(yarn global bin)"

autoload -U edit-command-line
bindkey -M vicmd v edit-command-line
set -o vi

dcleanup(){
  echo "removing containers"
    docker rm -v $(docker ps --filter status=exited -q 2>/dev/null) 2>/dev/null
    echo "removing images"
    docker rmi $(docker images --filter dangling=true -q 2>/dev/null) 2>/dev/null
}

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
 fi

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true

# Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
