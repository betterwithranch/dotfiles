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
alias bfg="java -jar /usr/bin/bfg-1.12.0.jar"

# ruby/rails aliases
alias wip="bundle exec cucumber --profile wip"
alias bi="bundle install"
alias rc="bundle exec rails c"
alias c="bundle exec cucumber --tags ~@rachel-wip --tags ~@wip --tags ~@travis-wip --tags ~@kbeckman-wip"
alias s="bundle exec rspec spec"
alias j="brake jasmine"
alias jc="RAILS_ENV=test brake jasmine:ci"
alias cs="brake spec cucumber"
alias resetTest="RAILS_ENV=test brake db:reset"
alias csj="s && c && jc"
alias spec="bundle exec rspec"
alias rspec="bundle exec rspec"
alias jsspec="RAILS_ENV=test bundle exec rake spec:javascript"
# I will no longer be thwarted by this typo
alias jkrspec="bundle exec rspec"
alias jrspec="bundle exec rspec"
alias tag="ctags -R --exclude=.bundle"

alias fixtures="bundle exec spec spec/controllers --tag fixtures"
alias autotester="bundle exec autotest"
alias boom="bundle install && bundle exec rake db:migrate db:test:prepare"

alias testcalc="VERBOSE_RISK_CALCS=true brake spec:risk_calcs"
alias tci="brake teamcity:ci"

# gem management
alias remove_all_gems='gem list | cut -d" " -f1 | xargs gem uninstall -aIx'
#alias gemset="rvm gemset use $1"

# migrations
alias dbm="bin/rake db:migrate"
alias dbmt="bin/rake db:migrate db:test:prepare"
alias dbs="brake db:seed"
alias dbmr="brake db:migrate:redo"
alias dbrollback="brake db:rollback"
alias dbr="dbrollback"
alias dbt="RAILS_ENV=test dbm"
alias tp="brake db:test:prepare"
alias routes="brake routes"

# postgres help
alias usepg93="export PATH=/Applications/Postgres93.app/Contents/MacOS/bin/:$PATH"

# process aliases
alias running="ps aux | grep "
# bash customizations
export CLICOLOR=1;
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
export PS1=" \[\033[38m\]\u\[\033[01;34m\] \w \[\033[31m\]\`ruby -e \"print (%x{git branch 2> /dev/null}.split(%r{\n}).grep(/^\*/).first || '').gsub(/^\* (.+)$/, '(\1) ')\"\`\[\033[37m\]$\[\033[00m\] "

# Virtual box manager
alias vbox="sudo /Library/StartupItems/VirtualBox/VirtualBox"
# rvm
#[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"  # This loads RVM into a shell session.
#source ~/.rvm/scripts/rvm
#PS1="\[\033[31m\]\$(~/.rvm/bin/rvm-prompt)\[\033[00m\] $PS1"

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
export EDITOR=vim
VIM=~/.vimrc
set -o vi

usepg() {
  echo $PATH;
}

# Add the following to your ~/.bashrc or ~/.zshrc
#
# Alternatively, copy/symlink this file and source in your shell.  See `hitch --setup-path`.

hitch() {
  command hitch "$@"
  if [[ -s "$HOME/.hitch_export_authors" ]] ; then source "$HOME/.hitch_export_authors" ; fi
}
alias unhitch='hitch -u'

# Uncomment to persist pair info between terminal instances
# hitch
# Add the following to your ~/.bashrc or ~/.zshrc
#
# Alternatively, copy/symlink this file and source in your shell.  See `hitch --setup-path`.

hitch() {
  command hitch "$@"
  if [[ -s "$HOME/.hitch_export_authors" ]] ; then source "$HOME/.hitch_export_authors" ; fi
}
alias unhitch='hitch -u'

# Uncomment to persist pair info between terminal instances
# hitch
