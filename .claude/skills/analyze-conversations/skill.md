# Analyze Conversations Skill

Analyze Claude Code conversation transcripts to extract feedback patterns for skill improvement.

## Trigger

Use when user asks to:
- "analyze conversations"
- "analyze today's conversations"
- "analyze feedback"
- "what feedback did I give"
- "review my corrections"

## Instructions

Run the analysis script using Bash:

```bash
# Today (default)
~/.claude/scripts/analyze-daily-conversations.py

# Specific date
~/.claude/scripts/analyze-daily-conversations.py --date YYYY-MM-DD

# JSON output (for programmatic use)
~/.claude/scripts/analyze-daily-conversations.py --output json
```

For analyzing multiple days (e.g., "this week"), run the script for each day and aggregate results.

## What the Script Does

1. Finds sanctum project transcripts for the target date
2. Filters user messages for corrective language patterns (regex)
3. Classifies feedback using Claude Sonnet via Bedrock
4. Outputs categorized feedback items with actionable instructions

## After Running

Summarize the key findings and offer to update the obsidian suggestions doc at:
`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/sanctum/Projects/Code Quality/suggestions.md`
