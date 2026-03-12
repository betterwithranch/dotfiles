#!/usr/bin/env zsh

echo
echo
echo "Tmux"
echo
echo

TPM_PATH=$HOME/.tmux/plugins/tpm

if [ ! -d "$TPM_PATH" ]; then
  echo "Installing TPM (tmux plugin manager)"
  if ! git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"; then
    echo "Error installing TPM. Exiting ..."
    return 1
  fi
else
  echo "TPM already installed"
fi

echo "Installing tmux plugins via TPM"
if ! "$TPM_PATH/bin/install_plugins"; then
  echo "Error installing tmux plugins. Exiting ..."
  return 1
fi
