#!/usr/bin/env zsh

echo
echo
echo "Github"
echo
echo

if [ ! -f ~/.ssh/id_ed25519 ]; then
  echo "Creating ssh key"
  ssh-keygen -t ed25519 -C "$(git config user.email)" -N '' -f ~/.ssh/id_ed25519
else
  echo "ssh key exists"
fi

grep id_ed25519.pub ~/.ssh/gh_keys &>/dev/null || gh auth status | grep "Logged in to github.com"

if [ $? -ne 0 ]; then
  gh auth login -h github.com -s admin:public_key
  gh ssh-key add ~/.ssh/id_ed25519.pub
  grep -q id_ed25519.pub ~/.ssh/gh_keys 2>/dev/null || echo id_ed25519.pub >> ~/.ssh/gh_keys
fi
