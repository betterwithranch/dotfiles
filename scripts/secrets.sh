#!/usr/bin/env zsh

local test_mode=false
if [[ "$1" == "--test" ]]; then
  test_mode=true
fi

echo
echo
if $test_mode; then
  echo "Secrets (1Password) — TEST MODE"
else
  echo "Secrets (1Password)"
fi
echo
echo

# Check if signed in
if ! op account list &>/dev/null; then
  echo "Please sign in to 1Password CLI first: eval \$(op signin)"
  return 1
fi

# Select account for template downloads
local accounts=("${(@f)$(op account list --format json | jq -r '.[].url')}")
local tpl_account=""
if [[ ${#accounts[@]} -gt 1 ]]; then
  echo "Select account for template downloads:"
  for i in {1..${#accounts[@]}}; do
    echo "  $i) ${accounts[$i]}"
  done
  echo -n "Account [1]: "
  read -r acct_choice
  [[ -z "$acct_choice" ]] && acct_choice=1
  tpl_account="${accounts[$acct_choice]}"
else
  tpl_account="${accounts[1]}"
fi
echo "Using account: $tpl_account"
echo

# Download templates to temp dir, inject secrets, clean up
# Items tagged "env-tpl" are documents with a "path" field for the output target
local tmpdir=$(mktemp -d)
trap "rm -rf $tmpdir" EXIT

echo "Checking for templates in 1Password..."
local inject_count=0
TPL_DOCS=("${(@f)$(op item list --tags env-tpl --account "$tpl_account" --format json 2>/dev/null | jq -r '.[].title' 2>/dev/null)}")
for doc_title in "${TPL_DOCS[@]}"; do
  [[ -z "$doc_title" ]] && continue
  local target_path
  target_path=$(op item get "$doc_title" --account "$tpl_account" --fields path --format json 2>/dev/null | jq -r '.value // empty' 2>/dev/null)
  if [[ -z "$target_path" ]]; then
    echo "  Skipping '$doc_title' — no 'path' field set"
    continue
  fi
  # Expand ~ and strip .tpl to get the output target
  target_path="${target_path/#\~/$HOME}"
  local target="${target_path%.tpl}"
  local target_dir="${target:h}"
  if [[ ! -d "$target_dir" ]]; then
    echo "  Skipping '$doc_title' — directory $target_dir does not exist"
    continue
  fi
  # Download template to temp dir
  local tpl_file="$tmpdir/$(basename "$target_path")"
  op document get "$doc_title" --account "$tpl_account" --out-file "$tpl_file" --force 2>/dev/null
  # Inject secrets from temp template into target (or .out file in test mode)
  if $test_mode; then
    local out_file="${target}.out"
    echo "  Injecting $doc_title -> $out_file (test)"
    if ! op inject -f -i "$tpl_file" -o "$out_file"; then
      echo "Error injecting $doc_title"
      return 1
    fi
    if [[ -f "$target" ]]; then
      local diff_output
      diff_output=$(diff "$target" "$out_file" 2>&1)
      if [[ $? -eq 0 ]]; then
        echo "    No differences"
      else
        echo "    Differences found:"
        echo "$diff_output" | sed 's/^/    /'
      fi
    else
      echo "    Target $target does not exist yet (new file)"
    fi
    rm -f "$out_file"
    echo
  else
    echo "  Injecting $doc_title -> $target"
    if ! op inject -f -i "$tpl_file" -o "$target"; then
      echo "Error injecting $doc_title"
      return 1
    fi
  fi
  ((inject_count++))
done

if [[ $inject_count -eq 0 ]]; then
  echo "No templates found in 1Password"
  return 0
fi

if $test_mode; then
  echo "Test complete ($inject_count templates compared)"
else
  echo "Secrets injected successfully ($inject_count templates)"
fi
