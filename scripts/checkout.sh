#!/usr/bin/env zsh

echo
echo
echo Checking out dotfiles repo
echo
echo

# define config alias locally since the dotfiles
# aren't installed on the system yet
function config {
  /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}

# Force https for dotfiles repo
git config --global url."https://github.com/betterwithranch/dotfiles.git".insteadOf https://github.com/betterwithranch/dotfiles.git

git -C $HOME/.dotfiles rev-parse

if [ $? -ne 0 ]; then

  echo "Cloning dotfiles repo ..."
  git clone --bare https://github.com/betterwithranch/dotfiles.git $HOME/.dotfiles

  if [ $? -ne 0 ]; then
    echo "Could not clone repo. Exiting ..."
    exit 1
  fi

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

  if [ $? -ne 0 ]; then
    echo "Error checking out dotfiles"
    exit 1
  fi
else
  echo "committing"
  config add .gitconfig && config commit -m "commits https gitconfig for pull"
  if [ $? -ne 0 ]; then
    echo "Error committing temp .gitconfig"
    exit 1
  fi

  echo "pulling latest from repo"
  config pull --rebase

  if [ $? -ne 0 ]; then
    echo "Error pulling latest dotfiles"
    exit 1
  fi

  # Reset temporary commit
  echo "resetting commit"
  config reset HEAD^

  if [ $? -ne 0 ]; then
    echo "Error committing temp .gitconfig"
    exit 1
  fi
fi

git config --global --remove-section url."git@github.com:"

if [ $? -ne 0 ]; then
  echo "Error checking out dotfiles"
  exit 1
fi

config config status.showUntrackedFiles no
if [ $? -ne 0 ]; then
  echo "Error updating showUntrackedFiles config"
  exit 1
fi

if [ $? = 0 ]; then
  echo "Checkout completed successfully"
else
  echo "Error removing https insteadOf"
  exit 1
fi
