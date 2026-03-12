#!/usr/bin/env zsh

if [[ "$1" == "--remote" ]]; then
  curl https://raw.githubusercontent.com/betterwithranch/dotfiles/main/scripts/init.sh | zsh
else
  RUN_LOCAL=1 source "$HOME/scripts/init.sh"
fi
