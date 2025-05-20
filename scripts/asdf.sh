#!/usr/bin/env zsh

# Ruby
asdf plugin list | grep ruby &>/dev/null ||
  asdf add ruby
RUBY_VERSIONS=(3.0.6 3.1.2 3.1.4)

for version in $RUBY_VERSIONS; do
  asdf list ruby | grep $version &>/dev/null ||
    asdf install ruby $version
done

# Node
asdf plugin list | grep nodejs &>/dev/null ||
  asdf plugin add nodejs
NODE_VERSIONS=(16.20.2 18.19.0 20.12.2)

for version in $NODE_VERSIONS; do
  asdf list nodejs | grep $version &>/dev/null ||
    asdf install nodejs $version
done

# Python
asdf plugin list | grep nodejs &>/dev/null ||
  asdf plugin add python
PYTHON_VERSIONS=(3.8.3 3.10.8 3.11.10)

for version in $PYTHON_VERSIONS; do
  asdf list python | grep $version &>/dev/null ||
    asdf install python $version
done
