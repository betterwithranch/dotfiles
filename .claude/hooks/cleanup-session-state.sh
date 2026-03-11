#!/bin/bash
# Log session usage and clean up per-session state file when session ends

input=$(cat)
SESSION_ID=$(echo "$input" | jq -r '.session_id // empty')
TRANSCRIPT_PATH=$(echo "$input" | jq -r '.transcript_path // empty')

USAGE_LOG="$HOME/.claude/session-usage.jsonl"
STATE_FILE="$HOME/.claude/session-state/${SESSION_ID}.json"

if [ -n "$SESSION_ID" ] && [ -f "$STATE_FILE" ]; then
  # Read token counts from state file
  INPUT_TOKENS=$(jq -r '.input_tokens // 0' "$STATE_FILE" 2>/dev/null)
  OUTPUT_TOKENS=$(jq -r '.output_tokens // 0' "$STATE_FILE" 2>/dev/null)
  CWD=$(jq -r '.cwd // empty' "$STATE_FILE" 2>/dev/null)

  # Extract conversation summary from transcript
  SUMMARY=""
  if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    # Get first user message as summary (truncate to 100 chars)
    SUMMARY=$(jq -r 'select(.type == "human") | .message.content | if type == "array" then map(select(.type == "text") | .text) | join(" ") else . end' "$TRANSCRIPT_PATH" 2>/dev/null | head -1 | cut -c1-100)
  fi

  # Get project name from cwd
  PROJECT=""
  if [ -n "$CWD" ]; then
    PROJECT=$(basename "$CWD")
  fi

  # Only log if we have token data
  if [ "$INPUT_TOKENS" -gt 0 ] || [ "$OUTPUT_TOKENS" -gt 0 ]; then
    # Append to usage log
    jq -nc \
      --arg sid "$SESSION_ID" \
      --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --argjson input "$INPUT_TOKENS" \
      --argjson output "$OUTPUT_TOKENS" \
      --arg project "$PROJECT" \
      --arg summary "$SUMMARY" \
      '{session_id: $sid, timestamp: $ts, input_tokens: $input, output_tokens: $output, project: $project, summary: $summary}' \
      >> "$USAGE_LOG"
  fi

  # Clean up state file
  rm -f "$STATE_FILE" 2>/dev/null
fi

# Also clean up any stale state files older than 1 day
find "$HOME/.claude/session-state" -type f -name "*.json" -mtime +1 -delete 2>/dev/null
