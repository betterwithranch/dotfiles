#!/usr/bin/env bash

set -e

echo "Bootstrapping workspace system"

defaults write com.apple.dock mru-spaces -bool false
killall Dock || true

SESSIONS=(personal sanctum sendcarrot mergefreeze)

for s in "${SESSIONS[@]}"; do
  if ! tmux has-session -t "$s" 2>/dev/null; then
    tmux new-session -d -s "$s"
  fi
done

open -a Hammerspoon || true

echo "Workspace bootstrap complete"
