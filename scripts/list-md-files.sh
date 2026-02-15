#!/bin/bash
# List markdown files from configured notes directory for Alfred Script Filter
# Outputs Alfred JSON format

CONFIG_FILE="$HOME/.config/aerospace/notes-dir.txt"

# Read notes directory from config (skip comments and empty lines)
if [ ! -f "$CONFIG_FILE" ]; then
    echo '{"items":[{"title":"Notes directory not configured","subtitle":"Create ~/.config/aerospace/notes-dir.txt with your notes folder path","valid":false}]}'
    exit 0
fi

NOTES_DIR=""
while IFS= read -r line || [ -n "$line" ]; do
    # Skip comments and empty lines
    case "$line" in
        \#*|"") continue ;;
    esac
    NOTES_DIR="$line"
    break
done < "$CONFIG_FILE"

# Expand ~ manually
case "$NOTES_DIR" in
    "~/"*) NOTES_DIR="$HOME/${NOTES_DIR#\~/}" ;;
    "~") NOTES_DIR="$HOME" ;;
esac

if [ -z "$NOTES_DIR" ]; then
    echo '{"items":[{"title":"No path configured","subtitle":"Add a folder path to ~/.config/aerospace/notes-dir.txt","valid":false}]}'
    exit 0
fi

if [ ! -d "$NOTES_DIR" ]; then
    echo '{"items":[{"title":"Directory not found","subtitle":"'"$NOTES_DIR"' does not exist","valid":false}]}'
    exit 0
fi

# Collect .md files
items=""
count=0
for f in "$NOTES_DIR"/*.md; do
    [ -f "$f" ] || continue
    filename="$(basename "$f")"
    name="${filename%.md}"
    name_escaped="${name//\"/\\\"}"
    path_escaped="${f//\"/\\\"}"
    if [ -n "$items" ]; then
        items="${items},"
    fi
    items="${items}{\"title\":\"${name_escaped}\",\"subtitle\":\"${path_escaped}\",\"arg\":\"${path_escaped}\",\"match\":\"${name_escaped}\"}"
    count=$((count + 1))
done

if [ "$count" -eq 0 ]; then
    echo '{"items":[{"title":"No markdown files found","subtitle":"No .md files in '"$NOTES_DIR"'","valid":false}]}'
    exit 0
fi

echo "{\"items\":[${items}]}"
