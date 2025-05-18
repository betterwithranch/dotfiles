#!/usr/bin/env bash

echo
echo
echo "Homebrew"
echo
echo

brew --version &>/dev/null

if [ $? -ne 0 ]; then
  echo "Homebrew is not installed. Installing ..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Homebrew is installed"

echo "Installing homebrew packages"

brew bundle --file ~/.Brewfile
if [ $? -ne 0 ]; then
  echo "An error occurred installing homebrew packages. Exiting ..."
  exit 1
fi
