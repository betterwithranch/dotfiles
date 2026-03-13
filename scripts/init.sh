#!/usr/bin/env zsh

if ! grep -q "auth\s*sufficient\s*pam_tid.so" /etc/pam.d/sudo_local 2>/dev/null; then
  echo "Setting up touch id for sudo commands"
  if [ -f /etc/pam.d/sudo_local.template ] && grep -q "pam_tid.so" /etc/pam.d/sudo_local.template; then
    if [ -f /etc/pam.d/sudo_local ]; then
      sudo cp /etc/pam.d/sudo_local "/etc/pam.d/sudo_local.bak.$(date +%s)"
    fi
    if ! sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local; then
      echo "Error updating sudo_local. Exiting ..."
    fi
  else
    echo "Warning: sudo_local.template not found or missing pam_tid.so. Skipping Touch ID setup."
  fi
fi

# Install Xcode command line tools
if [[ -z "${RUN_LOCAL}" ]]; then
  curl https://raw.githubusercontent.com/betterwithranch/dotfiles/main/scripts/xcode-select.sh | bash
else
  source "$HOME/scripts/xcode-select.sh"
fi

# Checkout dotfiles repo
if [[ -z "${RUN_LOCAL}" ]]; then
  curl https://raw.githubusercontent.com/betterwithranch/dotfiles/main/scripts/checkout.sh | bash
else
  source "$HOME/scripts/checkout.sh"
fi

# define config alias locally since the dotfiles
# aren't installed on the system yet
function config {
  /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

# Install oh-my-zsh
source "$HOME/scripts/oh-my-zsh.sh"

# Install tmux plugins
source "$HOME/scripts/tmux.sh"

# Install homebrew
source "$HOME/scripts/homebrew.sh"

# Symlink Alfred workflows
source "$HOME/scripts/alfred.sh"

# Install Claude Code
curl -fsSL https://claude.ai/install.sh | bash

# Install asdf languages
source "$HOME/scripts/asdf.sh"

if ! grep -q "/opt/homebrew/lib/pam/pam_reattach.so" /etc/pam.d/sudo_local; then
  echo "Adding pam-reattach"

  if ! sudo sed -i '' '/auth[[:space:]]*sufficient[[:space:]]*pam_tid.so/i\
    auth     optional     /opt/homebrew/lib/pam/pam_reattach.so\
    ' /etc/pam.d/sudo_local; then
    echo "Error updating pam-reattach"
  fi
fi

source "$HOME/scripts/mac-defaults.sh"

# Set up Finder sidebar favorites
source "$HOME/scripts/finder-favorites.sh"

# Install neovim plugins
echo "Installing neovim plugins"
nvim --headless "+Lazy! sync" +qa

# Restore temporary git config changes
config checkout .gitconfig

# Inject secrets from 1Password
source "$HOME/scripts/secrets.sh"

# Install ssh key on github
source "$HOME/scripts/github.sh"

echo
echo
echo Initialization is complete
echo
echo
