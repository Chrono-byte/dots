# Ellie's Dotfiles

A dotfiles setup managed by [Flux](https://forgejo.disilla.org/chrono/flux), Ellie's Rust CLI for linking configuration from a Git repository into application paths under the user's home directory.

## Overview

This repository stores application configuration and agent skills. The root `config.toml` tells Flux which files and folders to link and where they belong. Once linked, edits through an application's configuration path also change the repository copy. Git commits and pushes share those changes between machines.

See [the agent guide](docs/agents/flux.md) for mapping examples, commands, installation behavior, and verification.

## Repository Structure

```markdown
.dotfiles/
├── config.toml # Flux configuration file
├── scripts/ # Various utils
├── alacritty/ # Alacritty terminal emulator configs
├── cursor/ # Cursor editor settings
├── fonts/ # Font files for the system
├── starship/ # Starship prompt configuration
├── sway/ # Sway window manager configs
├── waybar/ # Waybar status bar configs
├── zed/ # Zed editor settings
├── zsh/ # Z shell configuration
└── .zed/ # Editor config for this repo
```

## Usage

### Initial Setup

1. Clone this repository to `~/.dotfiles`
2. Install Flux (refer to Flux documentation for installation)
3. Preview installation with `flux --config ~/.dotfiles/config.toml apply --dry-run --diff`.
4. Run `flux --config ~/.dotfiles/config.toml apply` after reviewing the preview. Use `--force` when you intend to replace existing local configuration with repository content.
