#!/usr/bin/env zsh
set -euo pipefail

arg="$1"

if [[ "$arg" == "__health__" ]]; then
  hs -c 'require("workspace_manager").workspaceHealth()'
else
  hs -c "require(\"workspace_manager\").switchWorkspace(\"$arg\")"
fi
