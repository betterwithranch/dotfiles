export dev=~/dev
export PATH="/usr/local/bin:/usr/local/sbin:$dev/dotfiles/scripts:$PATH"
export AUTOFEATURE=true

alias ll="ls -al"
alias brake="bundle exec rake"
alias ss=". ~/.bashrc"
alias tmux="TERM=screen-256color-bce tmux"
alias start_liveon="~/dev/tmux_liveon.sh"
alias stop_liveon="~/dev/tmux_shutdown.sh && tmux kill-session"

# always include line numbers for grep
alias grep="grep -n"
alias gri="grep -R -i"

# git
alias gs="git status"
alias gpom="git push origin master"
alias pushorigin="hack && cs && ship"

# ruby/rails aliases
alias wip="bundle exec cucumber --profile wip"
alias bi="bundle install"
alias c="bundle exec cucumber --tags ~@rachel-wip --tags ~@wip --tags ~@travis-wip --tags ~@kbeckman-wip"
alias s="bundle exec rspec spec"
alias j="brake jasmine"
alias jc="RAILS_ENV=test brake jasmine:ci"
alias cs="brake spec cucumber"
alias csj="s && c && jc"
alias spec="bundle exec rspec"
alias rspec="bundle exec rspec"
alias fixtures="bundle exec spec spec/controllers --tag fixtures"
alias autotester="bundle exec autotest"

alias testcalc="VERBOSE_RISK_CALCS=true brake spec:risk_calcs"
alias tci="brake teamcity:ci"

# gem management
alias remove_all_gems='gem list | cut -d" " -f1 | xargs gem uninstall -aIx'
#alias gemset="rvm gemset use $1"

# migrations
alias dbmigrate="brake db:migrate"
alias migrate="dbmigrate"
alias dbm="dbmigrate"
alias dbs="brake db:seed"
alias dbmr="brake db:migrate:redo"
alias dbrollback="brake db:rollback"
alias dbr="dbrollback"
alias preptest="brake db:test:prepare"
alias testprep="brake db:test:prepare"
alias tp="brake db:test:prepare"
alias routes="brake routes"

# bash customizations
export CLICOLOR=1;
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
export PS1=" \[\033[38m\]\u\[\033[01;34m\] \w \[\033[31m\]\`ruby -e \"print (%x{git branch 2> /dev/null}.split(%r{\n}).grep(/^\*/).first || '').gsub(/^\* (.+)$/, '(\1) ')\"\`\[\033[37m\]$\[\033[00m\] "
#PS1="\[\033[31m\]\$(~/.rvm/bin/rvm-prompt)\[\033[00m\] $PS1"

# rvm
#[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"  # This loads RVM into a shell session.
#source ~/.rvm/scripts/rvm

GIT_VER=`git --version | cut -f3 -d' '`
if [ -f /usr/local/Cellar/git/$GIT_VER/etc/bash_completion.d/git-completion.bash ]; then
  source /usr/local/Cellar/git/$GIT_VER/etc/bash_completion.d/git-completion.bash 
fi

#PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
if [ -e ~/.local_aliases ]
then
  . ~/.local_aliases
fi

if [ -e ~/.aws ]
then
  . ~/.aws
fi
VIM=~/.vimrc
set -o vi
