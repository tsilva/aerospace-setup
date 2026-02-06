#!/bin/bash

# macOS Animation Toggle Script
# Disables/enables animations that affect tiling window manager responsiveness
# Usage: ./toggle-animations.sh [on|off]

set -e

if [ "$1" = "off" ]; then
    echo "Disabling macOS animations..."

    # Window opening/closing animations
    defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

    # Mission Control / workspace transition speed
    defaults write com.apple.dock expose-animation-duration -float 0

    # Dock auto-hide delay and animation
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0

    # Window resize animation
    defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

    killall Dock 2>/dev/null || true

    echo "Animations disabled. Log out and back in for full effect."

elif [ "$1" = "on" ]; then
    echo "Re-enabling macOS animations..."

    defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool true
    defaults write com.apple.dock expose-animation-duration -float 0.1
    defaults delete com.apple.dock autohide-delay 2>/dev/null || true
    defaults delete com.apple.dock autohide-time-modifier 2>/dev/null || true
    defaults delete NSGlobalDomain NSWindowResizeTime 2>/dev/null || true

    killall Dock 2>/dev/null || true

    echo "Animations re-enabled. Log out and back in for full effect."

else
    echo "Usage: $0 [on|off]"
    echo "  off  - Disable all animations (snappy mode)"
    echo "  on   - Re-enable default animations"
    exit 1
fi
