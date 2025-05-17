#!/usr/bin/env bash
set -e

echo
echo
echo "Homebrew"
echo
echo

if which brew && brew --version; then
  echo "Homebrew is installed"
else
  echo "Installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
