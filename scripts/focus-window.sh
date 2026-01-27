#!/bin/bash
# Focus a Cursor window by ID
# Called by Alfred workflow after selecting a project

# Auto-detect aerospace binary
AEROSPACE=$(command -v aerospace || echo "/opt/homebrew/bin/aerospace")
if [ ! -x "$AEROSPACE" ]; then
    AEROSPACE="/usr/local/bin/aerospace"
fi

window_id="$1"
"$AEROSPACE" focus --window-id "$window_id"
