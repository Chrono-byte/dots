# Ellie's Dotfiles

A dotfiles repository managed by [Flux](https://forgejo.disilla.org/chrono/flux), my Rust CLI for linking repository files into application paths under my home directory.

## Overview

The root `config.toml` maps application configuration and agent skills to paths under my home directory. Those paths link to files in this repository, so editing a linked file changes the repository copy. Git syncs repository changes across my machines.

See [the agent guide](docs/agents/flux.md) for mapping examples, commands, installation behavior, and verification.

## Repository Structure

```
.dotfiles/
├── config.toml # Flux configuration file
├── codex/ # Codex configuration and skills view
├── pi/agent/ # my-pi-setup Git submodule
├── pi/skills/ # Pi skills view
├── skills/shared/ # Common skill files used by both agents
├── scripts/ # Utility scripts
├── alacritty/ # Alacritty terminal emulator configs
├── fonts/ # Font files for the system
├── starship/ # Starship prompt configuration
├── sway/ # Sway window manager configs
├── waybar/ # Waybar status bar configs
├── zed/ # Zed editor settings
├── zsh/ # Z shell configuration
└── .zed/ # Editor config for this repo
```

### Local shell secrets

Both zsh configurations source `~/.zshrc.secrets` when it is readable. Flux does not link this file.

To create it, copy `zsh/.zshrc.secrets.example` to `~/.zshrc.secrets` and edit the copy. The example contains no credentials or exports. Keep credentials out of Git. Files named `.zshrc.secrets` at the repository root or under `zsh/` are ignored.
