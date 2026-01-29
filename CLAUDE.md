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

**Cursor Window Organization (`alt+shift+s`):** The `aerospace-fix-cursor.sh` script reads project priorities from `cursor-projects.txt`, queries all Cursor windows via `aerospace list-windows`, then assigns workspaces starting at 2 (workspace 1 is reserved for utility apps). Priority-listed projects get lower numbers; remaining projects are assigned alphabetically.

**Alfred Integration:** Two Alfred workflows are installed. The **Cursor Project Switcher** (`p` keyword) uses `list-all-repos.sh` to scan `~/repos/tsilva/` for all repo directories and cross-references with open Cursor windows, outputting Alfred Script Filter JSON with open repos (showing workspace number) sorted first, then unopened repos alphabetically. `focus-window.sh` receives `open|<window-id>` to focus an existing window, or `new|<repo-path>` to open Cursor in the repo, run rearrange, and focus the new window. The **Quick Idea Capture** (`c` keyword) provides an Alfred keyword input that runs `capture home "{query}"` (requires the [capture](https://github.com/tsilva/capture) CLI to be installed separately).

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
