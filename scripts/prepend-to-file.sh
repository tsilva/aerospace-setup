#!/bin/bash
# Show a text input dialog and prepend the entered text to a markdown file
# Usage: prepend-to-file.sh <file-path>

FILE_PATH="$1"
if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

FILENAME="$(basename "$FILE_PATH")"

# Show text input dialog via osascript
NOTE=$(osascript -e "
    try
        set result to display dialog \"Add note to ${FILENAME}:\" default answer \"\" buttons {\"Cancel\", \"Add\"} default button \"Add\" with title \"Add Note\"
        return text returned of result
    on error
        return \"\"
    end try
" 2>/dev/null)

# Exit if cancelled or empty
if [ -z "$NOTE" ]; then
    exit 0
fi

# Prepend text to file using temp file
TMPFILE=$(mktemp)
printf '%s\n\n' "$NOTE" > "$TMPFILE"
cat "$FILE_PATH" >> "$TMPFILE"
mv "$TMPFILE" "$FILE_PATH"
