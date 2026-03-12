#!/usr/bin/env zsh

echo
echo
echo "Alfred"
echo
echo

ALFRED_WORKFLOW_DIR="$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows"
mkdir -p "$ALFRED_WORKFLOW_DIR"
for workflow in "$HOME/.alfred/workflows"/*/; do
    workflow_name=$(basename "$workflow")
    target="$ALFRED_WORKFLOW_DIR/$workflow_name"
    if [ ! -e "$target" ]; then
      echo "Linking Alfred workflow: $workflow_name"
      ln -s "$workflow" "$target"
    fi
done
