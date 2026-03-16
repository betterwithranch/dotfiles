#!/usr/bin/env zsh

set -euo pipefail

# Usage: ./env-to-tpl.sh <env-file>
# Interactively converts a .env file into a .tpl file with 1Password references.
# Progress is saved after each decision so you can restart without re-answering.

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <env-file>"
  echo "       $0 <env-file> --reset   # clear saved progress"
  exit 1
fi

ENV_FILE="$1"
TPL_FILE="${ENV_FILE}.tpl"
PROGRESS_FILE="${ENV_FILE}.tpl.progress"

if [[ "${2:-}" == "--reset" ]]; then
  rm -f "$PROGRESS_FILE"
  echo "Progress cleared for $ENV_FILE"
  exit 0
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "File not found: $ENV_FILE"
  exit 1
fi

# Check 1Password CLI
if ! command -v op &>/dev/null; then
  echo "1Password CLI (op) not found. Install it first."
  exit 1
fi

if ! op account list &>/dev/null; then
  echo "Please sign in to 1Password CLI first: eval \$(op signin)"
  exit 1
fi

# Load saved progress into an associative array
# Format: KEY<TAB>plain  or  KEY<TAB>op://vault/item/field<TAB>type<TAB>existing
typeset -A saved_decisions
if [[ -f "$PROGRESS_FILE" ]]; then
  while IFS=$'\t' read -r pkey pref ptype pexisting psection; do
    saved_decisions[$pkey]="${pref}"$'\t'"${ptype}"$'\t'"${pexisting}"$'\t'"${psection:--}"
  done < "$PROGRESS_FILE"
  echo "Loaded ${#saved_decisions[@]} saved decisions from previous run."
  echo "Use --reset to start over."
  echo
fi

save_decision() {
  # Args: key, ref (plain or op://...), type (text/password/-), existing (true/false), section (optional)
  printf '%s\t%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4" "${5:--}" >> "$PROGRESS_FILE"
}

# Select 1Password account
echo
echo "=== 1Password Setup ==="
echo
accounts=("${(@f)$(op account list --format json | jq -r '.[].url')}")
if [[ ${#accounts[@]} -gt 1 ]]; then
  echo "Select account:"
  for i in {1..${#accounts[@]}}; do
    echo "  $i) ${accounts[$i]}"
  done
  echo -n "Account [1]: "
  read -r acct_choice
  [[ -z "$acct_choice" ]] && acct_choice=1
  OP_ACCOUNT="${accounts[$acct_choice]}"
else
  OP_ACCOUNT="${accounts[1]}"
  echo "Account: $OP_ACCOUNT"
fi
OP_ACCT_FLAG=(--account "$OP_ACCOUNT")

# Fetch vaults for this account
vaults=("${(@f)$(op vault list "${OP_ACCT_FLAG[@]}" --format json | jq -r '.[].name')}")
echo
echo "Select default vault:"
for i in {1..${#vaults[@]}}; do
  echo "  $i) ${vaults[$i]}"
done
echo -n "Vault [1]: "
read -r vault_choice
[[ -z "$vault_choice" ]] && vault_choice=1
default_vault="${vaults[$vault_choice]}"
echo
echo -n "Default section name for custom fields [Environment]: "
read -r default_section
[[ -z "$default_section" ]] && default_section="Environment"
echo
echo "Using: $OP_ACCOUNT / $default_vault / section: $default_section"
echo "(You can override the vault per-secret during the walkthrough)"

# Secret heuristic patterns
SECRET_KEY_PATTERNS='(SECRET|TOKEN|KEY|PASSWORD|PASS|AUTH_TOKEN|AUTH|API_KEY|SID|CREDENTIAL|PRIVATE_KEY)'
NON_SECRET_KEY_PATTERNS='(^WORKTREE_|_PORT$|_HOST$|_NAME$|_TYPE$|_ENABLED$|_PROJECT$|_REGION$|_ENDPOINT$|_OFFSET$|^PG|^DB_HOST|^DB_NAME|^DB_USER|^DB_PORT|^AI_PROVIDER|^CHAT_AI_MODEL|^OBJC_)'
LOCAL_DEV_VALUES='(localhost|password|otter|test|true|false|key|unset)'

guess_is_secret() {
  local key="$1" value="$2"
  [[ "$value" == \$* ]] && echo "n" && return
  [[ -z "$value" ]] && echo "n" && return
  [[ "$value" =~ ^[0-9]+$ ]] && echo "n" && return
  [[ "$key" =~ ${~NON_SECRET_KEY_PATTERNS} ]] && echo "n" && return
  local stripped="${value//\"/}"
  stripped="${stripped//\'/}"
  [[ "$stripped" =~ ^${~LOCAL_DEV_VALUES}$ ]] && echo "n" && return
  [[ "$key" =~ ${~SECRET_KEY_PATTERNS} ]] && echo "y" && return
  if [[ ${#stripped} -gt 30 ]] && [[ "$stripped" =~ ^[A-Za-z0-9+/=_-]+$ ]]; then
    echo "y" && return
  fi
  echo "n"
}

guess_field_type() {
  local key="$1"
  [[ "$key" =~ ${~SECRET_KEY_PATTERNS} ]] && echo "password" && return
  echo "text"
}

# Track last-used vault and item for faster entry
last_vault="$default_vault"
last_item=""

# Collect secrets grouped by vault/item for batch creation
# Format: vault::item -> newline-separated "field[type]=value" pairs
typeset -A item_fields

# Output lines for the .tpl file
tpl_lines=()

echo
echo "=== env-to-tpl: Interactive .env to 1Password template converter ==="
echo "Source: $ENV_FILE"
echo "Output: $TPL_FILE"
echo
echo "For each variable, decide if it should be stored in 1Password."
echo "1Password values get op:// references in the template."
echo "Others stay as plain text."
echo

while IFS= read -r line <&3; do
  # Preserve blank lines and comments as-is
  if [[ -z "$line" || "$line" == \#* ]]; then
    tpl_lines+=("$line")
    continue
  fi

  # Parse KEY=VALUE
  if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
    key="${match[1]}"
    value="${match[2]}"
  else
    tpl_lines+=("$line")
    continue
  fi

  # Check for saved decision
  if [[ -n "${saved_decisions[$key]:-}" ]]; then
    local saved="${saved_decisions[$key]}"
    local saved_ref="${saved%%$'\t'*}"
    local saved_rest="${saved#*$'\t'}"
    local saved_type="${saved_rest%%$'\t'*}"
    saved_rest="${saved_rest#*$'\t'}"
    local saved_existing="${saved_rest%%$'\t'*}"
    local saved_section="${saved_rest#*$'\t'}"
    [[ "$saved_section" == "-" ]] && saved_section=""

    if [[ "$saved_ref" == "plain" ]]; then
      echo "  ${key} -> plain (saved)"
      tpl_lines+=("$line")
    else
      echo "  ${key} -> ${saved_ref} (saved)"
      tpl_lines+=("${key}=${saved_ref}")

      # Rebuild item_fields for non-existing items
      if [[ "$saved_existing" != "true" ]]; then
        local sv="${saved_ref#op://}"
        local sv_parts=("${(@s:/:)sv}")
        local sv_vault="${sv_parts[1]}"
        local sv_item="${sv_parts[2]}"
        local sv_field="${sv_parts[3]}"
        local ik="${sv_vault}::${sv_item}"
        local typed
        if [[ -n "$saved_section" ]]; then
          typed="${saved_section}.${sv_field}[${saved_type}]=${value}"
        else
          typed="${sv_field}[${saved_type}]=${value}"
        fi
        if [[ -n "${item_fields[$ik]:-}" ]]; then
          item_fields[$ik]="${item_fields[$ik]}"$'\n'"${typed}"
        else
          item_fields[$ik]="${typed}"
        fi
        last_vault="$sv_vault"
        last_item="$sv_item"
      fi
    fi
    continue
  fi

  # Guess and ask
  guess=$(guess_is_secret "$key" "$value")
  if [[ "$guess" == "y" ]]; then
    default_label="Y/n"
  else
    default_label="y/N"
  fi

  # Display with truncated value for long secrets
  display_value="$value"
  if [[ ${#display_value} -gt 50 ]]; then
    display_value="${display_value:0:20}...${display_value: -10}"
  fi

  echo "----------------------------------------"
  echo "  ${key}=${display_value}"
  echo -n "  1Password? [${default_label}]: "
  read -r answer

  if [[ -z "$answer" ]]; then
    answer="$guess"
  else
    answer="${answer:l}"
  fi

  if [[ "$answer" == "y" ]]; then
    # Prompt for vault (number, op:// ref, 's' to skip, '?' for list)
    local skipped=false
    local op_ref_used=false
    while true; do
      echo -n "  Vault [$last_vault] (? list, s skip, or paste op://): "
      read -r vault_input
      if [[ "${vault_input:l}" == "s" ]]; then
        echo "  Skipped — keeping as plain text."
        tpl_lines+=("$line")
        save_decision "$key" "plain" "-" "false"
        skipped=true
        break
      elif [[ "${vault_input//\"/}" == op://* ]]; then
        vault_input="${vault_input//\"/}"
        vault_input="${vault_input//\'/}"
        local ref="${vault_input#op://}"
        local ref_parts=("${(@s:/:)ref}")
        vault="${ref_parts[1]}"
        item="${ref_parts[2]}"
        if [[ ${#ref_parts[@]} -ge 3 && -n "${ref_parts[3]}" ]]; then
          field="${ref_parts[3]}"
        else
          field=""
        fi
        op_ref_used=true
        break
      elif [[ -z "$vault_input" ]]; then
        vault="$last_vault"
        break
      elif [[ "$vault_input" == "?" ]]; then
        for i in {1..${#vaults[@]}}; do
          echo "    $i) ${vaults[$i]}"
        done
      elif [[ "$vault_input" =~ ^[0-9]+$ ]] && (( vault_input >= 1 && vault_input <= ${#vaults[@]} )); then
        vault="${vaults[$vault_input]}"
        break
      else
        vault="$vault_input"
        break
      fi
    done
    [[ "$skipped" == true ]] && continue
    last_vault="$vault"

    if [[ "$op_ref_used" == true ]]; then
      last_item="$item"
      if [[ -n "$field" ]]; then
        echo "  -> op://${vault}/${item}/${field}"
      else
        echo -n "  Field [$key]: "
        read -r field_input
        [[ -z "$field_input" ]] && field="$key" || field="$field_input"
        echo "  -> op://${vault}/${item}/${field}"
      fi

      tpl_lines+=("${key}=op://${vault}/${item}/${field}")
      save_decision "$key" "op://${vault}/${item}/${field}" "-" "true"
    else
      # Prompt for item
      if [[ -n "$last_item" ]]; then
        echo -n "  Item [$last_item]: "
      else
        echo -n "  Item: "
      fi
      read -r item
      [[ -z "$item" ]] && item="$last_item"
      last_item="$item"

      # Prompt for field
      echo -n "  Field [$key]: "
      read -r field_input
      [[ -z "$field_input" ]] && field="$key" || field="$field_input"

      # Prompt for field type
      local type_guess
      type_guess=$(guess_field_type "$key")
      if [[ "$type_guess" == "password" ]]; then
        echo -n "  Type [t)ext, P)assword]: "
      else
        echo -n "  Type [T)ext, p)assword]: "
      fi
      read -r type_input
      type_input="${type_input:l}"
      if [[ -z "$type_input" ]]; then
        field_type="$type_guess"
      elif [[ "$type_input" == p* ]]; then
        field_type="password"
      else
        field_type="text"
      fi

      # Prompt for section
      echo -n "  Section [$default_section]: "
      read -r section_input
      [[ -z "$section_input" ]] && section="$default_section" || section="$section_input"

      tpl_lines+=("${key}=op://${vault}/${item}/${field}")
      save_decision "$key" "op://${vault}/${item}/${field}" "$field_type" "false" "$section"

      # Queue for 1Password creation
      item_key="${vault}::${item}"
      local typed_field="${section}.${field}[${field_type}]=${value}"
      if [[ -n "${item_fields[$item_key]:-}" ]]; then
        item_fields[$item_key]="${item_fields[$item_key]}"$'\n'"${typed_field}"
      else
        item_fields[$item_key]="${typed_field}"
      fi
    fi
  else
    # Keep as plain text
    tpl_lines+=("$line")
    save_decision "$key" "plain" "-" "false"
  fi

done 3< "$ENV_FILE"

echo
echo "========================================="
echo "Summary"
echo "========================================="

if [[ ${#item_fields[@]} -eq 0 ]]; then
  echo
  echo "  No new 1Password items to create."
else
  # Show what will be created
  for item_key in "${(@k)item_fields}"; do
    vault="${item_key%%::*}"
    item="${item_key#*::}"
    echo
    echo "  Vault: $vault"
    echo "  Item:  $item"
    echo "  Fields:"
    while IFS= read -r field_line; do
      local raw_fname="${field_line%%=*}"
      local full_name="${raw_fname%%\[*}"
      local ftype="${raw_fname#*\[}"
      ftype="${ftype%\]}"
      echo "    - $full_name ($ftype)"
    done <<< "${item_fields[$item_key]}"
  done
fi

echo
echo -n "Create 1Password items and generate ${TPL_FILE}? [Y/n]: "
read -r confirm
confirm="${confirm:l}"
[[ -z "$confirm" ]] && confirm="y"

if [[ "$confirm" != "y" ]]; then
  echo "Aborted. Progress is saved — rerun to continue."
  exit 0
fi

# Create 1Password items
if [[ ${#item_fields[@]} -gt 0 ]]; then
  echo
  echo "Creating 1Password items..."
  for item_key in "${(@k)item_fields}"; do
    vault="${item_key%%::*}"
    item="${item_key#*::}"

    # Check if item already exists
    existing=$(op item get "$item" --vault "$vault" "${OP_ACCT_FLAG[@]}" --format json 2>/dev/null || echo "")

    # Build field arguments
    field_args=()
    while IFS= read -r field_line; do
      fname="${field_line%%=*}"
      fvalue="${field_line#*=}"
      fvalue="${fvalue#\"}"
      fvalue="${fvalue%\"}"
      fvalue="${fvalue#\'}"
      fvalue="${fvalue%\'}"
      field_args+=("${fname}=${fvalue}")
    done <<< "${item_fields[$item_key]}"

    if [[ -n "$existing" ]]; then
      # Check which fields are missing (match by label, ignoring section prefix)
      local existing_fields
      existing_fields=$(echo "$existing" | jq -r '[.fields[]?.label // empty] | .[]' 2>/dev/null || echo "")
      local missing_args=()
      for fa in "${field_args[@]}"; do
        # Extract bare field name: "Section.Field[type]=value" -> "Field"
        local fa_name="${fa%%\[*}"       # strip [type]=value
        fa_name="${fa_name##*.}"          # strip Section. prefix
        if ! echo "$existing_fields" | grep -qx "$fa_name"; then
          missing_args+=("$fa")
        fi
      done

      if [[ ${#missing_args[@]} -eq 0 ]]; then
        echo "  Item exists, all fields present: $item (vault: $vault)"
      else
        echo "  Add fields to existing item: $item (vault: $vault)"
        for fa in "${missing_args[@]}"; do
          local fa_display="${fa%%\[*}"
          echo "    - $fa_display"
        done
        echo -n "  Proceed? [Y/n/s(kip)]: "
        read -r item_confirm
        item_confirm="${item_confirm:l}"
        if [[ "$item_confirm" == "s" ]]; then
          echo "  Skipped."
        elif [[ "$item_confirm" == "n" ]]; then
          echo "  Aborted. Progress is saved — rerun to continue."
          exit 0
        else
          local failed_args=()
          for fa in "${missing_args[@]}"; do
            local fa_display="${fa%%\[*}"
            fa_display="${fa_display##*.}"
            local edit_err=""
            local edit_rc=0
            edit_err=$(op item edit "$item" --vault "$vault" "${OP_ACCT_FLAG[@]}" "${fa}" 2>&1) || edit_rc=$?
            if [[ $edit_rc -eq 0 ]]; then
              echo "    + $fa_display"
            else
              echo "    ERROR: $edit_err"
              failed_args+=("$fa")
            fi
          done

          if [[ ${#failed_args[@]} -gt 0 ]]; then
            echo "    WARNING: Could not add fields to '$item' via CLI."
            echo "    Add these fields manually in 1Password:"
            for fa in "${failed_args[@]}"; do
              local fa_display="${fa%%\[*}"
              fa_display="${fa_display##*.}"
              echo "      - $fa_display"
            done
          fi
        fi
      fi
    else
      echo "  Create new item: $item (vault: $vault)"
      for fa in "${field_args[@]}"; do
        local fa_display="${fa%%\[*}"
        echo "    - $fa_display"
      done
      echo -n "  Proceed? [Y/n/s(kip)]: "
      read -r item_confirm
      item_confirm="${item_confirm:l}"
      if [[ "$item_confirm" == "s" ]]; then
        echo "  Skipped."
      elif [[ "$item_confirm" == "n" ]]; then
        echo "  Aborted. Progress is saved — rerun to continue."
        exit 0
      else
        op item create --vault "$vault" --category login --title "$item" "${OP_ACCT_FLAG[@]}" "${field_args[@]}" >/dev/null
        echo "  Created."
      fi
    fi
    echo
  done
fi

# Write the .tpl file
echo
echo "Writing ${TPL_FILE}..."
printf '%s\n' "${tpl_lines[@]}" > "$TPL_FILE"

# Clean up progress file on success
rm -f "$PROGRESS_FILE"

echo "Done!"
echo
echo "  Template: $TPL_FILE"
echo "  Run 'op inject -i ${TPL_FILE} -o ${ENV_FILE}' to hydrate."
