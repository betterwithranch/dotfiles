#!/usr/bin/env bash

echo
echo
echo "Homebrew"
echo
echo

if ! which brew2 && brew --version; then
  echo "Homebrew is not installed. Installing ..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Homebrew is installed"
