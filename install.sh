#!/bin/bash
# Aerospace Setup Installer
# Installs aerospace configuration, scripts, and Alfred workflow

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AEROSPACE_CONFIG_DIR="$HOME/.config/aerospace"
ALFRED_WORKFLOWS_DIR="$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows"
CLAUDE_DIR="$HOME/.claude"

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
    echo
    echo "AeroSpace is required for this setup to work."
    echo "Install it first using Homebrew:"
    echo
    echo "  brew install --cask nikitabobko/tap/aerospace"
    echo
    read -p "Would you like to install AeroSpace now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v brew &> /dev/null; then
            echo "Installing AeroSpace via Homebrew..."
            brew install --cask nikitabobko/tap/aerospace
            AEROSPACE_PATH=$(command -v aerospace)
            if [ -z "$AEROSPACE_PATH" ]; then
                echo "✗ Installation succeeded but aerospace command not found in PATH"
                echo "  You may need to restart your terminal or add it to your PATH"
                exit 1
            fi
            echo "✓ AeroSpace installed at: $AEROSPACE_PATH"
            echo
            echo "Starting AeroSpace..."
            open -a AeroSpace
            sleep 2  # Give AeroSpace time to start
            echo "✓ AeroSpace started"
        else
            echo "✗ Homebrew not found!"
            echo "  Install Homebrew first: https://brew.sh"
            exit 1
        fi
    else
        echo "Please install AeroSpace and run this installer again."
        exit 1
    fi
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
mkdir -p "$CLAUDE_DIR"
echo "✓ Created $AEROSPACE_CONFIG_DIR"
echo "✓ Created $CLAUDE_DIR"
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

# Create symlink for Claude Code notification integration
echo "Setting up Claude Code integration..."
FOCUS_SYMLINK="$CLAUDE_DIR/focus-window.sh"
FOCUS_TARGET="$AEROSPACE_CONFIG_DIR/notification-focus-window.sh"

if [ -L "$FOCUS_SYMLINK" ]; then
    CURRENT_TARGET=$(readlink "$FOCUS_SYMLINK")
    if [ "$CURRENT_TARGET" = "$FOCUS_TARGET" ]; then
        echo "✓ Symlink already exists: $FOCUS_SYMLINK -> $FOCUS_TARGET"
    else
        echo "  Existing symlink points to: $CURRENT_TARGET"
        read -p "  Replace with aerospace-setup symlink? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm "$FOCUS_SYMLINK"
            ln -s "$FOCUS_TARGET" "$FOCUS_SYMLINK"
            echo "✓ Created symlink: $FOCUS_SYMLINK -> $FOCUS_TARGET"
        else
            echo "  Skipped (keeping existing symlink)"
        fi
    fi
elif [ -f "$FOCUS_SYMLINK" ]; then
    echo "  Existing file found at $FOCUS_SYMLINK"
    read -p "  Replace with symlink? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$FOCUS_SYMLINK"
        ln -s "$FOCUS_TARGET" "$FOCUS_SYMLINK"
        echo "✓ Created symlink: $FOCUS_SYMLINK -> $FOCUS_TARGET"
    else
        echo "  Skipped (keeping existing file)"
    fi
else
    ln -s "$FOCUS_TARGET" "$FOCUS_SYMLINK"
    echo "✓ Created symlink: $FOCUS_SYMLINK -> $FOCUS_TARGET"
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
echo "  ~/.aerospace.toml                        Main config"
echo "  ~/.config/aerospace/cursor-projects.txt  Project priorities"
echo "  ~/.config/aerospace/*.sh                 Helper scripts"
echo "  ~/.claude/focus-window.sh                Notification focus (symlink)"
