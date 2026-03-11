#!/usr/bin/env zsh

grep "auth\s*sufficient\s*pam_tid.so" /etc/pam.d/sudo_local

if [ $? -ne 0 ]; then
  echo "Setting up touch id for sudo commands"
  if [ -f /etc/pam.d/sudo_local.template ] && grep -q "pam_tid.so" /etc/pam.d/sudo_local.template; then
    if [ -f /etc/pam.d/sudo_local ]; then
      sudo cp /etc/pam.d/sudo_local "/etc/pam.d/sudo_local.bak.$(date +%s)"
    fi
    sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local

    if [ $? -ne 0 ]; then
      echo "Error updating sudo_local. Exiting ..."
    fi
  else
    echo "Warning: sudo_local.template not found or missing pam_tid.so. Skipping Touch ID setup."
  fi
fi

# Install Xcode command line tools

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
  /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@"
}

# Install oh-my-zsh
source "$HOME/scripts/oh-my-zsh.sh"
if [ $? -ne 0 ]; then
  exit 1
fi

# Install tmux plugins
source "$HOME/scripts/tmux.sh"
if [ $? -ne 0 ]; then
  exit 1
fi

# Install homebrew
source "$HOME/scripts/homebrew.sh"
if [ $? -ne 0 ]; then
  exit 1
fi

# Symlink Alfred workflows
ALFRED_WORKFLOW_DIR="$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows"
mkdir -p "$ALFRED_WORKFLOW_DIR"
for workflow in "$HOME/.alfred/workflows"/*/; do
    workflow_name=$(basename "$workflow")
    target="$ALFRED_WORKFLOW_DIR/$workflow_name"
    if [ ! -e "$target" ]; then
      echo "Linking Alfred workflow: $workflow_name"
      ln -s "$workflow" "$target"
    fi
done

# Install Claude Code
curl -fsSL https://claude.ai/install.sh | bash
if [ $? -ne 0 ]; then
  exit 1
fi

# Install asdf languages
source "$HOME/scripts/asdf.sh"
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

source "$HOME/scripts/mac-defaults.sh"
if [ $? -ne 0 ]; then
  exit 1
fi

# Install neovim plugins
echo "Installing neovim plugins"
nvim --headless "+Lazy! sync" +qa

# Restore temporary git config changes
config checkout .gitconfig

# Inject secrets from 1Password
source "$HOME/scripts/secrets.sh"
if [ $? -ne 0 ]; then
  exit 1
fi

# Install ssh key on github
source "$HOME/scripts/github.sh"

echo
echo
echo Initialization is complete
echo
echo
