#!/bin/bash
# Aerospace Setup Installer
# Installs aerospace configuration, scripts, and Alfred workflow

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AEROSPACE_CONFIG_DIR="$HOME/.config/aerospace"
ALFRED_WORKFLOWS_DIR="$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows"
CLAUDE_DIR="$HOME/.claude"

# Color and formatting constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Symbols
CHECKMARK="✓"
CROSS="✗"
WARNING="⚠"
INFO="ℹ"
ARROW="•"
BAR_EMPTY="░"
BAR_FILL="█"
SPINNER_CHARS=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

# Helper functions for rich output
print_header() {
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║        ${PURPLE}🚀${CYAN} Aerospace Setup Installer          ║${RESET}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════╝${RESET}"
    echo
}

print_step() {
    local step="$1"
    local total="$2"
    local message="$3"
    echo -e "${BLUE}${BOLD}Step $step/$total:${RESET} ${BOLD}$message${RESET}"
}

print_success() {
    echo -e "${GREEN}${CHECKMARK}${RESET} $1"
}

print_error() {
    echo -e "${RED}${CROSS}${RESET} $1"
}

print_warning() {
    echo -e "${YELLOW}${WARNING}${RESET} $1"
}

print_info() {
    echo -e "${BLUE}${INFO}${RESET} $1"
}

print_divider() {
    echo -e "${GRAY}────────────────────────────────────────────────${RESET}"
}

print_progress() {
    local current="$1"
    local total="$2"
    local width=20
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    printf "%s${BOLD}%3d%%${RESET} " "$BLUE" "$percent"
    printf "["
    for ((i=0; i<filled; i++)); do printf "${GREEN}${BAR_FILL}"; done
    for ((i=0; i<empty; i++)); do printf "${GRAY}${BAR_EMPTY}"; done
    printf "${RESET}] "
    echo -n "$3"
    echo
}

print_spinner() {
    local message="$1"
    local i=0
    while true; do
        printf "\r${BLUE}${SPINNER_CHARS[$i]}${RESET} $message"
        i=$(( (i+1) % ${#SPINNER_CHARS[@]} ))
        sleep 0.1
    done &
    SPINNER_PID=$!
}

stop_spinner() {
    if [[ -n "$SPINNER_PID" ]]; then
        kill $SPINNER_PID 2>/dev/null
        printf "\r\033[K"
    fi
}

print_table() {
    local title="$1"
    shift
    echo
    echo -e "${BOLD}$title${RESET}"
    echo -e "${GRAY}┌─────────────────────────────────────────────┐${RESET}"
    while [[ $# -gt 0 ]]; do
        local item="$1"
        shift
        printf "${GRAY}│${RESET} %-47s ${GRAY}│${RESET}\n" "$item"
    done
    echo -e "${GRAY}└─────────────────────────────────────────────┘${RESET}"
}

print_keybindings() {
    echo
    echo -e "${BOLD}⌨️  Keybindings${RESET}"
    echo -e "${GRAY}┌─────────────────┬──────────────────────────┐${RESET}"
    printf "${GRAY}│${RESET} %-15s ${GRAY}│${RESET} %-24s ${GRAY}│${RESET}\n" "Shortcut" "Action"
    echo -e "${GRAY}├─────────────────┼──────────────────────────┤${RESET}"
    printf "${GRAY}│${RESET} %-15s ${GRAY}│${RESET} %-24s ${GRAY}│${RESET}\n" "alt+1-9" "Switch to workspace"
    printf "${GRAY}│${RESET} %-15s ${GRAY}│${RESET} %-24s ${GRAY}│${RESET}\n" "alt+s" "Organize Cursor windows"
    printf "${GRAY}│${RESET} %-15s ${GRAY}│${RESET} %-24s ${GRAY}│${RESET}\n" "alt+p" "Alfred project switcher"
    printf "${GRAY}│${RESET} %-15s ${GRAY}│${RESET} %-24s ${GRAY}│${RESET}\n" "alt+f" "Toggle fullscreen"
    echo -e "${GRAY}└─────────────────┴──────────────────────────┘${RESET}"
}

print_config_files() {
    echo
    echo -e "${BOLD}📂 Configuration Files${RESET}"
    echo -e "${GRAY}┌─────────────────────────────────────────────────────────────────┐${RESET}"
    printf "${GRAY}│${RESET} %-71s ${GRAY}│${RESET}\n" "~/.aerospace.toml                           Main config"
    printf "${GRAY}│${RESET} %-71s ${GRAY}│${RESET}\n" "~/.config/aerospace/cursor-projects.txt     Project priorities"
    printf "${GRAY}│${RESET} %-71s ${GRAY}│${RESET}\n" "~/.config/aerospace/*.sh                    Helper scripts"
    printf "${GRAY}│${RESET} %-71s ${GRAY}│${RESET}\n" "~/.claude/focus-window.sh                   Notification focus"
    echo -e "${GRAY}└─────────────────────────────────────────────────────────────────┘${RESET}"
}

print_header

# Check prerequisites
print_step 1 7 "Checking prerequisites"

# Check for aerospace
if command -v aerospace &> /dev/null; then
    AEROSPACE_PATH=$(command -v aerospace)
    print_success "Aerospace found at: $AEROSPACE_PATH"
else
    print_error "Aerospace not found!"

    print_info "AeroSpace is required for this setup to work."
    print_info "Install it first using Homebrew:"
    echo
    echo "  brew install --cask nikitabobko/tap/aerospace"
    read -p "Would you like to install AeroSpace now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v brew &> /dev/null; then
            print_info "Installing AeroSpace via Homebrew..."
            brew install --cask nikitabobko/tap/aerospace
            AEROSPACE_PATH=$(command -v aerospace)
            if [ -z "$AEROSPACE_PATH" ]; then
                print_error "Installation succeeded but aerospace command not found in PATH"
                print_info "You may need to restart your terminal or add it to your PATH"
                exit 1
            fi
            print_success "AeroSpace installed at: $AEROSPACE_PATH"
            echo
            print_info "Starting AeroSpace..."
            open -a AeroSpace
            sleep 2  # Give AeroSpace time to start
            print_success "AeroSpace started"
        else
            print_error "Homebrew not found!"
            print_info "Install Homebrew first: https://brew.sh"
            exit 1
        fi
    else
        print_info "Please install AeroSpace and run this installer again."
        exit 1
    fi
fi

# Check for Alfred
if [ -d "$ALFRED_WORKFLOWS_DIR" ]; then
    print_success "Alfred workflows directory found"
else
    print_warning "Alfred workflows directory not found"
    print_info "Alfred workflow will not be installed"
    ALFRED_WORKFLOWS_DIR=""
fi

echo

# Check for existing installation
OVERWRITE_EXISTING=""
EXISTING_FILES=""

if [ -f "$HOME/.aerospace.toml" ]; then
    EXISTING_FILES="$EXISTING_FILES ~/.aerospace.toml"
fi

for script in "$SCRIPT_DIR/scripts/"*.sh; do
    script_name=$(basename "$script")
    if [ -f "$AEROSPACE_CONFIG_DIR/$script_name" ]; then
        EXISTING_FILES="$EXISTING_FILES $script_name"
        break  # Only need to find one to know there's an existing install
    fi
done

if [ -n "$EXISTING_FILES" ]; then
    print_info "Existing installation detected."
    read -p "Overwrite existing files? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        OVERWRITE_EXISTING="y"
    else
        OVERWRITE_EXISTING="n"
        print_info "Existing files will be preserved"
    fi
    echo
fi

# Create directories
print_step 2 7 "Creating directories"
mkdir -p "$AEROSPACE_CONFIG_DIR"
mkdir -p "$CLAUDE_DIR"
print_success "Created $AEROSPACE_CONFIG_DIR"
print_success "Created $CLAUDE_DIR"
echo

# Copy aerospace.toml
print_step 3 7 "Installing configuration files"
if [ -f "$HOME/.aerospace.toml" ]; then
    if [ "$OVERWRITE_EXISTING" = "y" ]; then
        cp "$SCRIPT_DIR/config/aerospace.toml" "$HOME/.aerospace.toml"
        print_success "Installed ~/.aerospace.toml"
    else
        print_info "Skipped (keeping existing config)"
    fi
else
    cp "$SCRIPT_DIR/config/aerospace.toml" "$HOME/.aerospace.toml"
    print_success "Installed ~/.aerospace.toml"
fi
echo

# Copy scripts
print_info "Installing helper scripts..."
for script in "$SCRIPT_DIR/scripts/"*.sh; do
    script_name=$(basename "$script")
    dest="$AEROSPACE_CONFIG_DIR/$script_name"
    if [ -f "$dest" ]; then
        if [ "$OVERWRITE_EXISTING" = "y" ]; then
            cp "$script" "$dest"
            chmod +x "$dest"
            print_success "Installed $script_name"
        else
            print_info "Skipped $script_name (keeping existing)"
        fi
    else
        cp "$script" "$dest"
        chmod +x "$dest"
        print_success "Installed $script_name"
    fi
done
echo

# Handle cursor-projects.txt
print_info "Setting up cursor-projects.txt..."
if [ -f "$AEROSPACE_CONFIG_DIR/cursor-projects.txt" ]; then
    print_success "Existing cursor-projects.txt found (keeping your customizations)"
else
    cp "$SCRIPT_DIR/config/cursor-projects.txt.example" "$AEROSPACE_CONFIG_DIR/cursor-projects.txt"
    print_success "Created cursor-projects.txt from template"
    print_info "Edit $AEROSPACE_CONFIG_DIR/cursor-projects.txt to set your project priorities"
fi
echo

# Create symlink for Claude Code notification integration
print_step 4 7 "Setting up integrations"
FOCUS_SYMLINK="$CLAUDE_DIR/focus-window.sh"
FOCUS_TARGET="$AEROSPACE_CONFIG_DIR/notification-focus-window.sh"

if [ -L "$FOCUS_SYMLINK" ]; then
    CURRENT_TARGET=$(readlink "$FOCUS_SYMLINK")
    if [ "$CURRENT_TARGET" = "$FOCUS_TARGET" ]; then
        print_success "Symlink already exists: $FOCUS_SYMLINK -> $FOCUS_TARGET"
    else
        if [ "$OVERWRITE_EXISTING" = "y" ]; then
            rm "$FOCUS_SYMLINK"
            ln -s "$FOCUS_TARGET" "$FOCUS_SYMLINK"
            print_success "Created symlink: $FOCUS_SYMLINK -> $FOCUS_TARGET"
        else
            print_info "Skipped (keeping existing symlink to: $CURRENT_TARGET)"
        fi
    fi
elif [ -f "$FOCUS_SYMLINK" ]; then
    if [ "$OVERWRITE_EXISTING" = "y" ]; then
        rm "$FOCUS_SYMLINK"
        ln -s "$FOCUS_TARGET" "$FOCUS_SYMLINK"
        print_success "Created symlink: $FOCUS_SYMLINK -> $FOCUS_TARGET"
    else
        print_info "Skipped (keeping existing file at $FOCUS_SYMLINK)"
    fi
else
    ln -s "$FOCUS_TARGET" "$FOCUS_SYMLINK"
    print_success "Created symlink: $FOCUS_SYMLINK -> $FOCUS_TARGET"
fi
echo

# Install Alfred workflow
if [ -n "$ALFRED_WORKFLOWS_DIR" ]; then
    print_info "Installing Alfred workflow..."
    # Cursor Project Switcher workflow
    WORKFLOW_DEST="$ALFRED_WORKFLOWS_DIR/user.workflow.cursor-project-switcher"
    mkdir -p "$WORKFLOW_DEST"
    sed "s|__HOME__|$HOME|g" "$SCRIPT_DIR/alfred/cursor-project-switcher/info.plist" > "$WORKFLOW_DEST/info.plist"
    print_success "Installed Alfred workflow: Cursor Project Switcher"
    print_info "Use 'p <project>' in Alfred to switch Cursor windows"
fi
echo

# Reload aerospace config
print_step 5 7 "Reloading configuration"
if "$AEROSPACE_PATH" reload-config 2>/dev/null; then
    print_success "Configuration reloaded"
else
    print_warning "Could not reload config (aerospace may not be running)"
    print_info "Start aerospace or reload manually"
fi
echo

# Offer to disable macOS animations
print_step 6 7 "Performance optimization"

print_info "macOS animations can slow down the tiling window experience."
read -p "Disable macOS animations for a snappier experience? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    "$AEROSPACE_CONFIG_DIR/toggle-animations.sh" off
    # Check if Reduce Motion needs manual setup (SIP-protected on macOS 26+)
    REDUCE_MOTION=$(defaults read com.apple.Accessibility ReduceMotionEnabled 2>/dev/null)
    if [ "$REDUCE_MOTION" != "1" ]; then
        echo
        print_warning "To also disable minimize/unminimize animations, enable Reduce Motion manually"

        print_info "System Settings > Accessibility > Display > Reduce Motion"
        read -p "Open System Settings now? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            open "x-apple.systempreferences:com.apple.Accessibility-Settings.extension"
        fi
    fi
fi
echo

# Check for capture and offer to enable keybinding
if [ -f "$HOME/.config/capture/alfred-search.sh" ]; then
    echo
    print_info "Capture (quick note capture) detected!"
    read -p "Enable alt+c keybinding for quick capture? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Uncomment the capture keybinding in aerospace.toml
        sed -i '' 's/^# alt-c = '\''exec-and-forget ~\/.config\/capture\/alfred-search.sh c'\''$/alt-c = '\''exec-and-forget ~\/.config\/capture\/alfred-search.sh c'\''/' "$HOME/.aerospace.toml"
        if "$AEROSPACE_PATH" reload-config 2>/dev/null; then
            print_success "Enabled alt+c keybinding for capture"
        else
            print_warning "Keybinding added but could not reload config"
        fi
    fi
fi

print_step 7 7 "Installation complete"

print_keybindings
print_config_files

echo -e "${GREEN}${BOLD}${CHECKMARK} Installation complete! Enjoy your enhanced AeroSpace experience!${RESET}"
