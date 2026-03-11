#!/bin/bash
# Track skill usage per-session for status line display

input=$(cat)

# Get session ID and skill name
SESSION_ID=$(echo "$input" | jq -r '.session_id // empty')
SKILL_NAME=$(echo "$input" | jq -r '.tool_input.skill // empty')

if [ -z "$SESSION_ID" ] || [ -z "$SKILL_NAME" ]; then
  exit 0
fi

# Update per-session state file (preserve existing token data)
STATE_DIR="$HOME/.claude/session-state"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/${SESSION_ID}.json"

# Read existing state to preserve token counts
if [ -f "$STATE_FILE" ]; then
  EXISTING=$(cat "$STATE_FILE")
  echo "$EXISTING" | jq \
    --arg skill "$SKILL_NAME" \
    --argjson ts "$(date +%s)" \
    '.active_skill = $skill | .skill_timestamp = $ts' \
    > "$STATE_FILE"
else
  # No existing state, create new
  jq -n \
    --arg skill "$SKILL_NAME" \
    --argjson ts "$(date +%s)" \
    '{active_skill: $skill, skill_timestamp: $ts, input_tokens: 0, output_tokens: 0}' \
    > "$STATE_FILE"
fi

# macOS notification
osascript -e "display notification \"Skill: $SKILL_NAME\" with title \"Claude Code\"" 2>/dev/null
