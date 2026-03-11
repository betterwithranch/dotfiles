#!/bin/bash
# Claude Code hook: Notify when Claude finishes responding
# Triggered by: Stop event

# Only notify if running inside tmux
if [ -z "$TMUX" ]; then
    exit 0
fi

# Capture tmux context
TMUX_SESSION=$(tmux display-message -p '#S')
TMUX_TARGET=$(tmux display-message -p '#S:#I.#P')

# Trigger Alfred workflow with context
open "alfred://runtrigger/com.sendcarrot.claude-notify/complete/?argument=${TMUX_SESSION}|${TMUX_TARGET}"
