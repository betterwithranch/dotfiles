#!/usr/bin/env zsh

echo
echo
echo "Tmux"
echo
echo

TPM_PATH=$HOME/.tmux/plugins/tpm

if [ ! -d "$TPM_PATH" ]; then
  echo "Installing TPM (tmux plugin manager)"
  git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"

  if [ $? -ne 0 ]; then
    echo "Error installing TPM. Exiting ..."
    exit 1
  fi
else
  echo "TPM already installed"
fi

echo "Installing tmux plugins via TPM"
"$TPM_PATH/bin/install_plugins"

if [ $? -ne 0 ]; then
  echo "Error installing tmux plugins. Exiting ..."
  exit 1
fi
