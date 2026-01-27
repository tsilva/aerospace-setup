#!/bin/bash
# Aerospace Setup Installer
# Installs aerospace configuration, scripts, and Alfred workflow

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AEROSPACE_CONFIG_DIR="$HOME/.config/aerospace"
ALFRED_WORKFLOWS_DIR="$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows"

echo "Aerospace Setup Installer"
echo "========================="
echo

# Check prerequisites
echo "Checking prerequisites..."

# Check for aerospace
if command -v aerospace &> /dev/null; then
    AEROSPACE_PATH=$(command -v aerospace)
    echo "✓ Aerospace found at: $AEROSPACE_PATH"
else
    echo "✗ Aerospace not found!"
    echo "  Install with: brew install nikitabobko/tap/aerospace"
    exit 1
fi

# Check for Alfred
if [ -d "$ALFRED_WORKFLOWS_DIR" ]; then
    echo "✓ Alfred workflows directory found"
else
    echo "⚠ Alfred workflows directory not found"
    echo "  Alfred workflow will not be installed"
    ALFRED_WORKFLOWS_DIR=""
fi

echo

# Create directories
echo "Creating directories..."
mkdir -p "$AEROSPACE_CONFIG_DIR"
echo "✓ Created $AEROSPACE_CONFIG_DIR"
echo

# Copy aerospace.toml
echo "Installing aerospace.toml..."
if [ -f "$HOME/.aerospace.toml" ]; then
    echo "  Existing config found at ~/.aerospace.toml"
    read -p "  Overwrite? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp "$SCRIPT_DIR/config/aerospace.toml" "$HOME/.aerospace.toml"
        echo "✓ Installed ~/.aerospace.toml"
    else
        echo "  Skipped (keeping existing config)"
    fi
else
    cp "$SCRIPT_DIR/config/aerospace.toml" "$HOME/.aerospace.toml"
    echo "✓ Installed ~/.aerospace.toml"
fi
echo

# Copy scripts
echo "Installing scripts..."
for script in "$SCRIPT_DIR/scripts/"*.sh; do
    script_name=$(basename "$script")
    dest="$AEROSPACE_CONFIG_DIR/$script_name"
    if [ -f "$dest" ]; then
        echo "  Existing script: $script_name"
        read -p "  Overwrite? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp "$script" "$dest"
            chmod +x "$dest"
            echo "✓ Installed $script_name"
        else
            echo "  Skipped"
        fi
    else
        cp "$script" "$dest"
        chmod +x "$dest"
        echo "✓ Installed $script_name"
    fi
done
echo

# Handle cursor-projects.txt
echo "Setting up cursor-projects.txt..."
if [ -f "$AEROSPACE_CONFIG_DIR/cursor-projects.txt" ]; then
    echo "✓ Existing cursor-projects.txt found (keeping your customizations)"
else
    cp "$SCRIPT_DIR/config/cursor-projects.txt.example" "$AEROSPACE_CONFIG_DIR/cursor-projects.txt"
    echo "✓ Created cursor-projects.txt from template"
    echo "  Edit $AEROSPACE_CONFIG_DIR/cursor-projects.txt to set your project priorities"
fi
echo

# Install Alfred workflow
if [ -n "$ALFRED_WORKFLOWS_DIR" ]; then
    echo "Installing Alfred workflow..."
    WORKFLOW_DEST="$ALFRED_WORKFLOWS_DIR/user.workflow.cursor-project-switcher"

    mkdir -p "$WORKFLOW_DEST"

    # Copy info.plist and replace __HOME__ placeholder
    sed "s|__HOME__|$HOME|g" "$SCRIPT_DIR/alfred/cursor-project-switcher/info.plist" > "$WORKFLOW_DEST/info.plist"
    echo "✓ Installed Alfred workflow"
    echo "  Use 'p <project>' in Alfred to switch Cursor windows"
fi
echo

# Reload aerospace config
echo "Reloading aerospace configuration..."
if "$AEROSPACE_PATH" reload-config 2>/dev/null; then
    echo "✓ Configuration reloaded"
else
    echo "⚠ Could not reload config (aerospace may not be running)"
    echo "  Start aerospace or reload manually"
fi
echo

echo "========================="
echo "Installation complete!"
echo
echo "Keybindings:"
echo "  alt+1-9     Switch to workspace"
echo "  alt+c       Organize Cursor windows"
echo "  alt+f       Toggle fullscreen"
echo "  p <project> Alfred: switch to Cursor project"
echo
echo "Configuration files:"
echo "  ~/.aerospace.toml                      Main config"
echo "  ~/.config/aerospace/cursor-projects.txt Project priorities"
echo "  ~/.config/aerospace/*.sh               Helper scripts"
