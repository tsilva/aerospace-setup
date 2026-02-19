<div align="center">
  <img src="logo.png" alt="aerospace-setup" width="512"/>

# aerospace-setup

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/tsilva/aerospace-setup/blob/main/LICENSE)
[![macOS](https://img.shields.io/badge/macOS-Sonoma+-black?logo=apple)](https://github.com/nikitabobko/AeroSpace)
[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://github.com/tsilva/aerospace-setup/tree/main/scripts)

**🚀 Portable Aerospace configuration with Cursor project switching via Alfred ⚡**

[Installation](#-installation) · [Features](#-features) · [Configuration](#%EF%B8%8F-configuration)

</div>

---

## ✨ Features

- **One-command setup** - Install all Aerospace configs, scripts, and Alfred workflow
- **Cursor window management** - Organize Cursor projects into numbered workspaces with `alt+s`
- **Alfred integration** - Browse all repos and switch or open Cursor projects with `alt+p`
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
4. Set up Alfred workflow for project switching
5. Reload Aerospace configuration

## ⌨️ Keybindings

| Keybinding | Action |
|------------|--------|
| `alt+1-9` | Switch to workspace 1-9 |
| `alt+shift+1-9` | Move window to workspace 1-9 |
| `alt+←/→` | Previous/next workspace |
| `alt+s` | Organize Cursor windows by priority |
| `alt+p` | Open Alfred project switcher (`p` keyword) |
| `alt+f` | Toggle fullscreen |
| `alt+c` | Quick capture (requires [capture](https://github.com/tsilva/capture)) |

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
│   ├── list-all-repos.sh         # Alfred script filter (all repos)
│   ├── list-cursor-windows.sh    # List open Cursor windows
│   └── focus-window.sh           # Focus or open project (Alfred)
└── alfred/
    └── cursor-project-switcher/
        └── info.plist            # Alfred project switcher workflow
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

## 📝 Capture Integration

If you use [capture](https://github.com/tsilva/capture) for quick note-taking, the installer will detect it and offer to enable the `alt+c` keybinding. This lets you capture thoughts instantly while working in any workspace.

The keybinding is commented out by default in `~/.aerospace.toml`. The installer will uncomment it if capture is detected, or you can enable it manually:

```toml
alt-c = 'exec-and-forget ~/.config/capture/alfred-search.sh c'
```

## 🗑️ Uninstall

```bash
./uninstall.sh
```

Removes all installed files. Aerospace itself is not uninstalled.

## 📄 License

MIT


## License

MIT
