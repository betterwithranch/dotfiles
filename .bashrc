# Minimal bashrc — zsh is the primary shell.
# This exists so tools that invoke /bin/bash (e.g. Claude Code) have a working PATH.

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)"

# Go
export GOPATH=~/dev/go
export PATH=$PATH:$GOPATH/bin

# Editor
export EDITOR=nvim

# direnv
if command -v direnv &>/dev/null; then
  eval "$(direnv hook bash)"
fi
