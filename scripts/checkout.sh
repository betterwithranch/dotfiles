#!/usr/bin/env bash

echo
echo
echo Checking out dotfiles repo
echo
echo

if [ -z "$DOTFILES_LOCAL" ]; then
  # Force https for dotfiles repo
  git config --global url."https://github.com/betterwithranch/dotfiles.git".insteadOf https://github.com/betterwithranch/dotfiles.git

  rm -rf $HOME/.dotfiles

  echo "Cloning dotfiles repo ..."
  git clone --bare https://github.com/betterwithranch/dotfiles.git $HOME/.dotfiles

  if [ $? -ne 0 ]; then
    echo "Could not clone repo. Exiting ..."
    exit 1
  fi

  # Remove https for dotfiles
  git config --global --remove-section url."https://github.com/betterwithranch/dotfiles.git"
fi

# define config alias locally since the dotfiles
# aren't installed on the system yet
function config {
  /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}

config checkout

if [ $? = 0 ]; then
  echo "Checked out dotfiles from git@github.com:betterwithranch/dotfiles.git"
else
  echo "Moving existing dotfiles to ~/.dotfiles-backup"
  FILES=$(config checkout 2>&1 | egrep "^\s+" | awk {'print $1'})

  for f in $FILES; do
    mkdir -p $(dirname $HOME/.dotfiles-backup/$f) &&
      mv $HOME/$f $HOME/.dotfiles-backup/$f
  done
fi

# checkout dotfiles from repo
config checkout
config config status.showUntrackedFiles no
if [ $? = 0 ]; then
  echo "Checkout completed successfully"
else
  echo "Checkout could not be completed"
  exit 1
fi
