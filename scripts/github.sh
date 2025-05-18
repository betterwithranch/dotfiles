#!/usr/bin/env zsh

echo
echo
echo "Github"
echo
echo

if [ ! -f ~/.ssh/id_rsa ]; then
  echo "Creating ssh key"
  ssh-keygen -t ed25519 -C "craig@theisraels.net" -N '' -f ~/.ssh/id_rsa
else
  echo "ssh key exists"
fi

gh auth status | grep "Logged in to github.com"

if [ $? -ne 0 ]; then
  gh auth login
  gh ssh-key add ~/.ssh/_id_rsa
fi
