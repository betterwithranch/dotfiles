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

grep id_rsa.pub ~/.ssh/gh_keys &>/dev/null || gh auth status | grep "Logged in to github.com"

if [ $? -ne 0 ]; then
  gh auth login -h github.com -s admin:public_key
  gh ssh-key add ~/.ssh/id_rsa.pub
  grep id_rsa.pub ~/.ssh/gh_keys &>/dev/null | echo id_rsa.pub >> ~/.ssh/gh_keys
fi
