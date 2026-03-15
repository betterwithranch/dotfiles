#!/usr/bin/env zsh
set -euo pipefail

WORKSPACE_DIR="$HOME/.config/hammerspoon/workspaces"

if [[ ! -d "$WORKSPACE_DIR" ]]; then
  echo '{"items":[{"title":"Workspace configs not found","subtitle":"Expected ~/.config/hammerspoon/workspaces","valid":false}]}'
  exit 0
fi

echo -n '{"items":['
first=1

for file in "$WORKSPACE_DIR"/*.lua(N); do
  name="${file:t:r}"
  display=$(grep -E 'name[[:space:]]*=' "$file" | head -1 | sed -E 's/.*"([^"]+)".*/\1/')
  icon=$(grep -E 'icon[[:space:]]*=' "$file" | head -1 | sed -E 's/.*"([^"]+)".*/\1/')

  [[ -z "$display" ]] && display="$name"
  [[ -z "$icon" ]] && icon="•"

  [[ $first -eq 0 ]] && echo -n ","
  first=0

  python3 - <<PY
import json
print(json.dumps({"title": f"{icon} {display}", "subtitle": f"Switch to {display}", "arg": "${name}"}), end="")
PY
done

[[ $first -eq 0 ]] && echo -n ","

echo '{"title":"🛠 Workspace Health","subtitle":"Repair workspace state","arg":"__health__"}'
echo ']}'
