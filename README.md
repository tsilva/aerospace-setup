<div align="center">

# aerospace-setup

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-Sonoma+-black?logo=apple)](https://github.com/nikitabobko/AeroSpace)
[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](scripts/)

**🚀 Portable Aerospace configuration with Cursor project switching via Alfred**

[Installation](#-installation) · [Features](#-features) · [Configuration](#%EF%B8%8F-configuration)

</div>

---

## ✨ Features

- **One-command setup** - Install all Aerospace configs, scripts, and Alfred workflow
- **Cursor window management** - Organize Cursor projects into numbered workspaces with `alt+c`
- **Alfred integration** - Switch to any Cursor project by typing `p <project>`
- **Project priorities** - Define which projects get lower workspace numbers
- **Cross-platform paths** - Auto-detects Homebrew location (Apple Silicon or Intel)

## 📦 Installation

### Prerequisites

```bash
# Install Aerospace (tiling window manager)
brew install nikitabobko/tap/aerospace

# Alfred 5 required for project switcher workflow
```

### Quick Install

```bash
git clone https://github.com/tsilva/aerospace-setup.git
cd aerospace-setup
./install.sh
```

The installer will:
1. Check for Aerospace and Alfred
2. Copy `aerospace.toml` to `~/.aerospace.toml`
3. Install helper scripts to `~/.config/aerospace/`
4. Set up the Alfred workflow for project switching
5. Reload Aerospace configuration

## ⌨️ Keybindings

| Keybinding | Action |
|------------|--------|
| `alt+1-9` | Switch to workspace 1-9 |
| `alt+shift+1-9` | Move window to workspace 1-9 |
| `alt+←/→` | Previous/next workspace |
| `alt+c` | Organize Cursor windows by priority |
| `alt+f` | Toggle fullscreen |
| `p <project>` | Alfred: switch to Cursor project |

## 🗂️ Project Structure

```
aerospace-setup/
├── install.sh                    # Main installer
├── uninstall.sh                  # Cleanup script
├── config/
│   ├── aerospace.toml            # Aerospace configuration
│   └── cursor-projects.txt.example  # Project priority template
├── scripts/
│   ├── aerospace-fix-cursor.sh   # Organize Cursor windows
│   ├── list-cursor-windows.sh    # Alfred script filter
│   └── focus-window.sh           # Focus window by ID
└── alfred/
    └── cursor-project-switcher/
        └── info.plist            # Alfred workflow
```

## ⚙️ Configuration

### Project Priorities

Edit `~/.config/aerospace/cursor-projects.txt` to set your project priority order:

```
my-main-project
side-project
experiments
```

Projects listed first get lower workspace numbers (starting at workspace 2). Projects not listed are assigned to subsequent workspaces alphabetically.

### Window Auto-Assignment

Apps are automatically moved to workspace 1:
- Chrome, Obsidian, ChatGPT, Claude, Sublime Text, WhatsApp

Edit `~/.aerospace.toml` to customize.

## 🗑️ Uninstall

```bash
./uninstall.sh
```

Removes all installed files. Aerospace itself is not uninstalled.

## 📄 License

MIT
