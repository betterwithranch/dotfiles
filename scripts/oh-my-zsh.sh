#!/usr/bin/env bash

echo
echo
echo "Oh-my-zsh"
echo
echo

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh-my-zsh is not installed. Installing ..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  if [ $? -ne 0 ]; then
    echo "Error installing oh-my-zsh. Exiting ..."
    exit 1
  fi

  config checkout .zshrc && rm ~/.zshrc.pre-oh-my-zsh
  if [ $? -ne 0 ]; then
    echo "Error restoring .zshrc file. Exiting ..."
    exit 1
  fi
fi

echo "Oh-my-zsh is installed"
