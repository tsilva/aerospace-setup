# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a portable configuration system for [AeroSpace](https://github.com/nikitabobko/AeroSpace), a macOS tiling window manager. The primary feature is Cursor IDE project organization - automatically assigning Cursor windows to numbered workspaces based on configurable project priorities, with Alfred integration for quick project switching.

## Installation & Testing

```bash
# Install everything (config, scripts, Alfred workflow)
./install.sh

# Remove all installed files
./uninstall.sh

# Manual config reload (after editing aerospace.toml)
aerospace reload-config
```

## Architecture

**Installer Flow:** `install.sh` copies `aerospace.toml` to `~/.aerospace.toml`, scripts to `~/.config/aerospace/`, creates project priority file from template, and installs Alfred workflow with `$HOME` path substitution via sed.

**Cursor Window Organization (`alt+c`):** The `aerospace-fix-cursor.sh` script reads project priorities from `cursor-projects.txt`, queries all Cursor windows via `aerospace list-windows`, then assigns workspaces starting at 2 (workspace 1 is reserved for utility apps). Priority-listed projects get lower numbers; remaining projects are assigned alphabetically.

**Alfred Integration:** `list-cursor-windows.sh` outputs Alfred Script Filter JSON format. It extracts project names from Cursor window titles (format: `filename — project-name`), sorted by workspace number. `focus-window.sh` receives the selected window ID as argument.

**Binary Detection:** All scripts auto-detect aerospace location via `command -v`, with fallbacks to `/opt/homebrew/bin/` (Apple Silicon) and `/usr/local/bin/` (Intel).

## Key Files After Installation

- `~/.aerospace.toml` - Main Aerospace configuration
- `~/.config/aerospace/cursor-projects.txt` - User's project priority list
- `~/.config/aerospace/*.sh` - Helper scripts
- `~/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows/user.workflow.cursor-project-switcher/` - Alfred workflow

## Development Notes

- Scripts must be bash 3.x compatible (macOS default) - avoid bash 4+ features like associative arrays
- Window IDs are obtained from `aerospace list-windows --all` output (first column)
- The `aerospace` CLI requires windows to be running; test with Cursor open
- README.md should be kept up to date with any significant project changes
