# Dotfiles Repository

A dotfiles setup using [Flux](https://forgejo.disilla.org/chrono/flux), a powerful dotfiles manager that handles configuration synchronization across multiple environments.

## Overview

This repository contains configuration files for various applications and tools, managed by Flux. The flux uses symlinks to keep configuration files synchronized between the repository and their actual destinations.

## Repository Structure

```markdown
.dotfiles/
├── config.toml              # Flux configuration file
├── scripts/                 # Utility and hook scripts
│   └── check-hostname.sh    # Pre-commit hook for hostname validation
├── alacritty/               # Alacritty terminal emulator configs
├── cursor/                  # Cursor editor settings
├── fonts/                   # Font files for the system
├── starship/                # Starship prompt configuration
├── sway/                    # Sway window manager configs
├── waybar/                  # Waybar status bar configs
├── zed/                     # Zed editor settings
└── zsh/                     # Z shell configuration
```

## Usage

### Initial Setup

1. Clone this repository to `~/.dotfiles`
2. Install Flux (refer to Flux documentation for installation)
3. Run `flux apply` to create all symlinks

## Hooks Example

The included `check-hostname.sh` hook demonstrates conditional execution:

- Runs before commits
- Only executes on specific hostnames (`anubis` in this case)
- Blocks commits if hostname condition fails
- Useful for environment-specific validations

This setup provides a robust, maintainable system for managing dotfiles across multiple machines and environments while keeping everything version-controlled and easily deployable.
