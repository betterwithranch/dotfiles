#!/usr/bin/env zsh

echo
echo
echo "asdf languages"
echo
echo

PLUGINS=(ruby nodejs python terraform)

for plugin in $PLUGINS; do
  asdf plugin list | grep "$plugin" &>/dev/null ||
    asdf plugin add "$plugin"
done

# Install versions from ~/.tool-versions
if ! asdf install; then
  echo "Error installing asdf languages. Exiting ..."
  return 1
fi
