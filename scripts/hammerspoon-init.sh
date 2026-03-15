#!/usr/bin/env bash

echo "Configuring Hammerspoon..."

mkdir -p "$HOME/.config/hammerspoon"

if [ ! -L "$HOME/.hammerspoon" ]; then
  echo "Linking ~/.hammerspoon → ~/.config/hammerspoon"
  rm -rf "$HOME/.hammerspoon"
  ln -s "$HOME/.config/hammerspoon" "$HOME/.hammerspoon"
fi

defaults write org.hammerspoon.Hammerspoon MJConsoleOnStartup -bool false

if ! pgrep -x "Hammerspoon" >/dev/null; then
  echo "Starting Hammerspoon..."
  open -g -a Hammerspoon
fi
