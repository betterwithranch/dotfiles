#!/usr/bin/env zsh
set -euo pipefail

arg="$1"

hs -c "require(\"workspace_manager\").openChromeWorkspace(\"$arg\")"
