#!/bin/bash
# Aerospace Setup Uninstaller
# Removes aerospace configuration, scripts, and Alfred workflow

set -e

AEROSPACE_CONFIG_DIR="$HOME/.config/aerospace"
ALFRED_WORKFLOW="$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows/user.workflow.cursor-project-switcher"
ALFRED_CAPTURE_WORKFLOW="$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows/user.workflow.quick-idea-capture"
FOCUS_SYMLINK="$HOME/.claude/focus-window.sh"
FOCUS_TARGET="$AEROSPACE_CONFIG_DIR/notification-focus-window.sh"

echo "Aerospace Setup Uninstaller"
echo "==========================="
echo

echo "This will remove:"
echo "  - ~/.aerospace.toml"
echo "  - ~/.config/aerospace/ (scripts and config)"
echo "  - Alfred Cursor Project Switcher workflow"
echo "  - Alfred Quick Idea Capture workflow"
echo "  - ~/.claude/focus-window.sh symlink (if it points to our script)"
echo

read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo

# Remove aerospace.toml
if [ -f "$HOME/.aerospace.toml" ]; then
    rm "$HOME/.aerospace.toml"
    echo "✓ Removed ~/.aerospace.toml"
else
    echo "  ~/.aerospace.toml not found"
fi

# Remove scripts directory
if [ -d "$AEROSPACE_CONFIG_DIR" ]; then
    rm -rf "$AEROSPACE_CONFIG_DIR"
    echo "✓ Removed $AEROSPACE_CONFIG_DIR"
else
    echo "  $AEROSPACE_CONFIG_DIR not found"
fi

# Remove Alfred workflows
if [ -d "$ALFRED_WORKFLOW" ]; then
    rm -rf "$ALFRED_WORKFLOW"
    echo "✓ Removed Alfred Cursor Project Switcher workflow"
else
    echo "  Alfred Cursor Project Switcher workflow not found"
fi

if [ -d "$ALFRED_CAPTURE_WORKFLOW" ]; then
    rm -rf "$ALFRED_CAPTURE_WORKFLOW"
    echo "✓ Removed Alfred Quick Idea Capture workflow"
else
    echo "  Alfred Quick Idea Capture workflow not found"
fi

# Remove focus-window.sh symlink (only if it points to our script)
if [ -L "$FOCUS_SYMLINK" ]; then
    CURRENT_TARGET=$(readlink "$FOCUS_SYMLINK")
    if [ "$CURRENT_TARGET" = "$FOCUS_TARGET" ]; then
        rm "$FOCUS_SYMLINK"
        echo "✓ Removed $FOCUS_SYMLINK symlink"
    else
        echo "  $FOCUS_SYMLINK points to different target, not removing"
    fi
else
    echo "  $FOCUS_SYMLINK not found or not a symlink"
fi

# Reload aerospace config if aerospace is still installed
if command -v aerospace &> /dev/null; then
    echo "Reloading aerospace configuration..."
    if aerospace reload-config 2>/dev/null; then
        echo "✓ Configuration reloaded"
    else
        echo "⚠ Could not reload config (aerospace may not be running)"
    fi
    echo
fi

echo "Uninstall complete."
echo
echo "Note: Aerospace itself is not uninstalled."
echo "To fully remove: brew uninstall aerospace"
