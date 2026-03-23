#!/usr/bin/env zsh
set -euo pipefail

hs -c 'require("workspace_manager").listChromeWorkspaces()'
