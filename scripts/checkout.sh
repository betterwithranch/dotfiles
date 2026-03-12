#!/usr/bin/env zsh

echo
echo
echo Checking out dotfiles repo
echo
echo

# define config alias locally since the dotfiles
# aren't installed on the system yet
function config {
  /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

if [ -d ~/.dotfiles ] && git -C "$HOME/.dotfiles" rev-parse 2>/dev/null; then
  # Repo exists — pull latest
  if ! config add -u -v || ! config commit -v --no-edit -m "temp commit for git pull"; then
    echo "Error adding/committing .gitconfig temporarily"
    return 1 2>/dev/null || exit 1
  fi

  echo "pulling latest from repo"
  if ! config pull --rebase; then
    echo "Error pulling latest dotfiles"
    return 1 2>/dev/null || exit 1
  fi

  # Reset temporary commit
  echo "resetting commit"
  if ! config reset --soft HEAD^ || ! config restore --staged .gitconfig; then
    echo "Error committing temp .gitconfig"
    return 1 2>/dev/null || exit 1
  fi
else
  # Fresh clone
  echo "Cloning dotfiles repo ..."
  if ! git clone --bare https://github.com/betterwithranch/dotfiles.git "$HOME/.dotfiles"; then
    echo "Could not clone repo. Exiting ..."
    return 1 2>/dev/null || exit 1
  fi

  if config checkout; then
    echo "Checked out dotfiles from git@github.com:betterwithranch/dotfiles.git"
  else
    echo "Moving existing dotfiles to ~/.dotfiles-backup"
    FILES=$(config checkout 2>&1 | egrep "^\s+" | awk {'print $1'})

    for f in ${(f)FILES}; do
      mkdir -p "$(dirname "$HOME/.dotfiles-backup/$f")" &&
        mv "$HOME/$f" "$HOME/.dotfiles-backup/$f"
    done
  fi

  # checkout dotfiles from repo
  if ! config checkout; then
    echo "Error checking out dotfiles"
    return 1 2>/dev/null || exit 1
  fi
fi

if ! config config status.showUntrackedFiles no; then
  echo "Error updating showUntrackedFiles config"
  return 1 2>/dev/null || exit 1
fi

echo "Checkout completed successfully"
