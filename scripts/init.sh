#!/usr/bin/env bash

echo "Setting up touch id for sudo commands"
sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local

if [ $? -ne 0 ]; then
  echo "Error updating sudo_local. Exiting ..."
fi

# Install Xcode command line tools

curl https://raw.githubusercontent.com/betterwithranch/dotfiles/main/scripts/xcode-select.sh | bash

if [ $? -ne 0]; then
  exit 1
fi

# Checkout dotfiles repo
curl https://raw.githubusercontent.com/betterwithranch/dotfiles/main/scripts/checkout.sh | bash
if [ $? -ne 0]; then
  exit 1
fi

# define config alias locally since the dotfiles
# aren't installed on the system yet
function config {
  /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}

SCRIPT_DIR=$(config rev-parse --show-toplevel)/scripts

# Install homebrew
source "$HOME/scripts/homebrew.sh"
if [ $? -ne 0]; then
  exit 1
fi

echo
echo
echo Initialization is complete
echo
echo
