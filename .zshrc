export EDITOR=vim
alias mux=tmuxinator
alias dbm="bundle exec rails db:migrate"
alias s="bundle exec rspec spec"
# set -o vi

installOhMyZsh() {
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}
