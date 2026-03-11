#!/bin/bash
# Claude Code status line with context usage progress bar and active skill

input=$(cat)

# Parse JSON input
USERNAME=$(whoami)
CWD=$(echo "$input" | jq -r '.cwd // empty')
PERCENT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
SESSION_ID=$(echo "$input" | jq -r '.session_id // empty')

# Get token counts
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
OUTPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# Format token count (e.g., 1.2M, 450K, 12K)
format_tokens() {
  local tokens=$1
  if [ "$tokens" -ge 1000000 ]; then
    printf "%.1fM" "$(echo "scale=1; $tokens / 1000000" | bc)"
  elif [ "$tokens" -ge 1000 ]; then
    printf "%.0fK" "$(echo "scale=0; $tokens / 1000" | bc)"
  else
    printf "%d" "$tokens"
  fi
}
INPUT_DISPLAY=$(format_tokens $INPUT_TOKENS)
OUTPUT_DISPLAY=$(format_tokens $OUTPUT_TOKENS)

# Get git branch
GIT_BRANCH=$(cd "$CWD" 2>/dev/null && git branch 2>/dev/null | grep '^\*' | sed 's/^\* //')

# Update per-session state with token counts (for SessionEnd tracking)
if [ -n "$SESSION_ID" ]; then
  STATE_DIR="$HOME/.claude/session-state"
  mkdir -p "$STATE_DIR"
  STATE_FILE="$STATE_DIR/${SESSION_ID}.json"

  # Read existing state to preserve skill info
  EXISTING_SKILL=""
  EXISTING_SKILL_TIME="0"
  if [ -f "$STATE_FILE" ]; then
    EXISTING_SKILL=$(jq -r '.active_skill // empty' "$STATE_FILE" 2>/dev/null)
    EXISTING_SKILL_TIME=$(jq -r '.skill_timestamp // 0' "$STATE_FILE" 2>/dev/null)
  fi

  # Write updated state with tokens
  jq -n \
    --arg skill "$EXISTING_SKILL" \
    --argjson skill_ts "$EXISTING_SKILL_TIME" \
    --argjson input "$INPUT_TOKENS" \
    --argjson output "$OUTPUT_TOKENS" \
    --arg cwd "$CWD" \
    '{active_skill: $skill, skill_timestamp: $skill_ts, input_tokens: $input, output_tokens: $output, cwd: $cwd}' \
    > "$STATE_FILE"
fi

# Check for active skill from per-session state
ACTIVE_SKILL=""
if [ -n "$SESSION_ID" ]; then
  STATE_FILE="$HOME/.claude/session-state/${SESSION_ID}.json"
  if [ -f "$STATE_FILE" ]; then
    SKILL_NAME=$(jq -r '.active_skill // empty' "$STATE_FILE" 2>/dev/null)
    SKILL_TIME=$(jq -r '.skill_timestamp // 0' "$STATE_FILE" 2>/dev/null)
    NOW=$(date +%s)
    # Show skill if it was activated within last 5 minutes
    if [ -n "$SKILL_NAME" ] && [ "$((NOW - SKILL_TIME))" -lt 300 ]; then
      ACTIVE_SKILL="$SKILL_NAME"
    fi
  fi
fi

# Create a progress bar (15 characters wide)
BAR_SIZE=15
FILLED=$((PERCENT * BAR_SIZE / 100))
if [ "$FILLED" -gt "$BAR_SIZE" ]; then
  FILLED=$BAR_SIZE
fi

BAR=$(printf '%*s' "$FILLED" | tr ' ' '█')
EMPTY=$(printf '%*s' "$((BAR_SIZE - FILLED))" | tr ' ' '░')

# Color the progress bar based on usage
if [ "$PERCENT" -ge 80 ]; then
  BAR_COLOR="\033[31m"  # Red
elif [ "$PERCENT" -ge 60 ]; then
  BAR_COLOR="\033[33m"  # Yellow
else
  BAR_COLOR="\033[32m"  # Green
fi
RESET="\033[00m"
MAGENTA="\033[35m"

# Build output
OUTPUT="\033[38m${USERNAME}\033[01;34m ${CWD}"

if [ -n "$GIT_BRANCH" ]; then
  OUTPUT="${OUTPUT} \033[31m(${GIT_BRANCH})${RESET}"
fi

OUTPUT="${OUTPUT} ${BAR_COLOR}[${BAR}${EMPTY}] ${PERCENT}%${RESET} ↓${INPUT_DISPLAY} ↑${OUTPUT_DISPLAY}"

if [ -n "$ACTIVE_SKILL" ]; then
  OUTPUT="${OUTPUT} ${MAGENTA}[${ACTIVE_SKILL}]${RESET}"
fi

printf "%b" "$OUTPUT"
