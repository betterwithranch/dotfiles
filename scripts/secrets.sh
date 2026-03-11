#!/usr/bin/env zsh

echo
echo
echo "Secrets (1Password)"
echo
echo

# Check if signed in
op account list &>/dev/null

if [ $? -ne 0 ]; then
  echo "Please sign in to 1Password CLI first: eval \$(op signin)"
  exit 1
fi

# Inject secrets from .tpl files
TEMPLATES=("${(@f)$(find "$HOME" -name "*.tpl" -path "*/.*" -maxdepth 3 2>/dev/null)}")

if [ ${#TEMPLATES[@]} -eq 0 ]; then
  echo "No secret templates found"
  return 0
fi

for tpl in "${TEMPLATES[@]}"; do
  target="${tpl%.tpl}"
  echo "Injecting secrets into $target"
  op inject -i "$tpl" -o "$target"

  if [ $? -ne 0 ]; then
    echo "Error injecting $tpl"
    exit 1
  fi
done

echo "Secrets injected successfully"
