#!/bin/bash
# Focus the correct Ghostty window and tmux pane
# Input: "session_name|session:window.pane"

IFS='|' read -r TMUX_SESSION TMUX_TARGET <<< "$1"

# AppleScript to find and activate correct Ghostty window
osascript << EOF
tell application "Ghostty"
    activate
    try
        set targetWindow to first window whose name contains "$TMUX_SESSION"
        set index of targetWindow to 1
    end try
end tell
EOF

# Select the correct tmux pane
tmux select-pane -t "$TMUX_TARGET" 2>/dev/null
