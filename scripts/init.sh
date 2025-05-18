#!/usr/bin/env zsh

grep "auth\s*sufficient\s*pam_tid.so" /etc/pam.d/sudo_local

if [ $? -ne 0 ]; then
  echo "Setting up touch id for sudo commands"
  sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local

  if [ $? -ne 0 ]; then
    echo "Error updating sudo_local. Exiting ..."
  fi
fi

# Install Xcode command line tools

echo $RUN_LOCAL
exit
if [[ -z "${RUN_LOCAL}" ]];then
  curl https://raw.githubusercontent.com/betterwithranch/dotfiles/main/scripts/xcode-select.sh | bash
else
  source $HOME/scripts/xcode-select.sh
fi

if [ $? -ne 0 ]; then
  exit 1
fi

# Checkout dotfiles repo
if [[ -z "${RUN_LOCAL}" ]];then
  curl https://raw.githubusercontent.com/betterwithranch/dotfiles/main/scripts/checkout.sh | bash
else
  source $HOME/scripts/checkout.sh
fi

if [ $? -ne 0 ]; then
  exit 1
fi

# define config alias locally since the dotfiles
# aren't installed on the system yet
function config {
  /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}

SCRIPT_DIR=$(config rev-parse --show-toplevel)/scripts

# Install oh-my-zsh
source "$HOME/scripts/oh-my-zsh.sh"
if [ $? -ne 0 ]; then
  exit 1
fi

# Install homebrew
source "$HOME/scripts/homebrew.sh"
if [ $? -ne 0 ]; then
  exit 1
fi

grep "/opt/homebrew/lib/pam/pam_reattach.so" /etc/pam.d/sudo_local

if [ $? -ne 0 ]; then
  echo "Adding pam-reattach"

  sudo sed -i '' '/auth[[:space:]]*sufficient[[:space:]]*pam_tid.so/i\
    auth     optional     /opt/homebrew/lib/pam/pam_reattach.so\
    ' /etc/pam.d/sudo_local

  if [ $? -ne 0 ]; then
    echo "Error updating pam-reattach"
  fi
fi

# Restore temporary git config changes
config checkout .gitconfig

echo
echo
echo Initialization is complete
echo
echo
