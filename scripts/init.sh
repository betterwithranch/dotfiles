#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo scriptdir=$SCRIPT_DIR

echo "Setting up touch id for sudo commands"
sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local

if [ $? -ne 0 ]; then
  echo "Error updating sudo_local. Exiting ..."
fi

/bin/bash -c "sudo echo test"
# Install Xcode command line tools
source "$SCRIPT_DIR/xcode-select.sh"

# Checkout dotfiles repo
source "$SCRIPT_DIR/checkout.sh"

# Install homebrew
source "$SCRIPT_DIR/homebrew.sh"

echo
echo
echo Initialization is complete
echo
echo
