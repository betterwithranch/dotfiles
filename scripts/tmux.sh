#!/usr/bin/env zsh

echo
echo
echo "Tmux"
echo
echo

CATPPUCCIN_PATH=$HOME/.config/tmux/plugins/catppuccin
mkdir -p $CATPPUCCIN_PATH

PLUGIN_PATH=$CATPPUCCIN_PATH/tmux

if [ ! -d $PLUGIN_PATH ]; then
  echo "Installing catppuccin plugin"
  git clone -b v2.1.3 https://github.com/catppuccin/tmux.git $PLUGIN_PATH
else
  pushd $PLUGIN_PATH
  echo "Checking out catppuccin plugin"
  git checkout

  CHECKOUT_RESULT=$?

  popd

  if [ $CHECKOUT_RESULT -ne 0 ]; then
    echo "Error checking out tmuz catppuccin plugin"
    exit 1
  fi
fi
