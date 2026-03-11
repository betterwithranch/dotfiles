#!/bin/bash
# Load project-specific env vars for MCP servers

LOG_FILE="$HOME/.claude/hooks/hooks.log"

echo "[$(date)] load-project-env.sh started" >> "$LOG_FILE"
echo "[$(date)] CLAUDE_PROJECT_DIR=$CLAUDE_PROJECT_DIR" >> "$LOG_FILE"
echo "[$(date)] CLAUDE_ENV_FILE=$CLAUDE_ENV_FILE" >> "$LOG_FILE"
echo "[$(date)] PWD=$PWD" >> "$LOG_FILE"
echo "[$(date)] CLAUDE env var names:" >> "$LOG_FILE"
env | grep -i claude | sed 's/=.*/=***/' >> "$LOG_FILE" 2>&1 || echo "[$(date)] No CLAUDE vars found" >> "$LOG_FILE"

if [ -f "$CLAUDE_PROJECT_DIR/.env.claude" ]; then
  echo "[$(date)] Found .env.claude file" >> "$LOG_FILE"
  while IFS='=' read -r key value; do
    # Skip comments and empty lines
    [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
    # Remove 'export ' prefix if present
    key="${key#export }"
    # Write to Claude's env file
    echo "[$(date)] Writing $key to CLAUDE_ENV_FILE" >> "$LOG_FILE"
    printf 'export %s=%s\n' "$key" "$value" >> "$CLAUDE_ENV_FILE"
  done < "$CLAUDE_PROJECT_DIR/.env.claude"
else
  echo "[$(date)] No .env.claude file found at $CLAUDE_PROJECT_DIR/.env.claude" >> "$LOG_FILE"
fi

echo "[$(date)] load-project-env.sh completed" >> "$LOG_FILE"
exit 0
