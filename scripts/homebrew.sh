#!/usr/bin/env zsh

echo
echo
echo "Homebrew"
echo
echo

if ! brew --version &>/dev/null; then
  echo "Homebrew is not installed. Installing ..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Homebrew is installed"

echo "Installing homebrew packages"

if ! brew bundle; then
  echo "An error occurred installing homebrew packages. Exiting ..."
  return 1
fi
