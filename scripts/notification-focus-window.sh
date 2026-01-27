#!/bin/bash
#
# AeroSpace Notification Focus Script
# Executed when user clicks a notification to focus the correct IDE window.
# Called via symlink at ~/.claude/focus-window.sh
#
# Usage: notification-focus-window.sh <workspace-name>
#

# Use full path since terminal-notifier runs with minimal PATH
AEROSPACE="/opt/homebrew/bin/aerospace"
if [ ! -x "$AEROSPACE" ]; then
    AEROSPACE="/usr/local/bin/aerospace"
fi

WORKSPACE="$1"

# Check if AeroSpace is available
if [ ! -x "$AEROSPACE" ]; then
    # Fallback: just activate Cursor via AppleScript
    osascript -e 'tell application "Cursor" to activate' 2>/dev/null
    exit 0
fi

# Find window ID for Cursor/Code with workspace in title
WINDOW_INFO=$("$AEROSPACE" list-windows --all --format '%{window-id}|%{app-name}|%{window-title}|%{workspace}' | \
    grep -E '(Cursor|Code)' | \
    grep -i "$WORKSPACE" | \
    head -1)

if [ -z "$WINDOW_INFO" ]; then
    # Fallback: first Cursor window
    WINDOW_INFO=$("$AEROSPACE" list-windows --all --format '%{window-id}|%{app-name}|%{window-title}|%{workspace}' | \
        grep -E '(Cursor|Code)' | \
        head -1)
fi

if [ -n "$WINDOW_INFO" ]; then
    WINDOW_ID=$(echo "$WINDOW_INFO" | cut -d'|' -f1)
    WINDOW_WORKSPACE=$(echo "$WINDOW_INFO" | cut -d'|' -f4)

    # Switch workspace and focus window
    [ -n "$WINDOW_WORKSPACE" ] && "$AEROSPACE" workspace "$WINDOW_WORKSPACE"
    "$AEROSPACE" focus --window-id "$WINDOW_ID"
else
    # Last resort: just activate Cursor
    osascript -e 'tell application "Cursor" to activate' 2>/dev/null
fi
