# Ellie's Dotfiles

A dotfiles setup managed by [Flux](https://forgejo.disilla.org/chrono/flux), Ellie's Rust CLI for linking configuration from a Git repository into application paths under the user's home directory.

## Overview

This repository stores application configuration and agent skills. The root `config.toml` tells Flux which files and folders to link and where they belong. Once linked, edits through an application's configuration path also change the repository copy. Git commits and pushes share those changes between machines.

See [the agent guide](docs/agents/flux.md) for mapping examples, commands, installation behavior, and verification.

## Repository Structure

```markdown
.dotfiles/
├── config.toml # Flux configuration file
├── codex/ # Codex configuration and skills view
├── pi/agent/ # my-pi-setup Git submodule
├── pi/skills/ # Pi skills view
├── skills/shared/ # Common skill files used by both agents
├── scripts/ # Various utils
├── alacritty/ # Alacritty terminal emulator configs
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

1. Clone this repository to `~/.dotfiles` with `git clone --recurse-submodules <repository-url> ~/.dotfiles`. For an existing checkout, run `git submodule update --init --recursive`.
2. Install Flux (refer to Flux documentation for installation)
3. Preview installation with `flux --config ~/.dotfiles/config.toml apply --dry-run --diff`.
4. Run `flux --config ~/.dotfiles/config.toml apply` after reviewing the preview. Use `--force` when you intend to replace existing local configuration with repository content.

Pi's [my-pi-setup](https://forgejo.disilla.org/chrono/my-pi-setup) repository is pinned as a submodule at `pi/agent`. See the [agent guide](docs/agents/flux.md) for its installed location and shared skills link.

### Checks

Run `python3 docs/check-dotfiles.py` (Python 3.11+) and `flux --config ~/.dotfiles/config.toml doctor` to check mappings and links. Preview installation with `flux --config ~/.dotfiles/config.toml apply --dry-run --diff`.

### Local shell secrets

Both zsh configurations optionally source `~/.zshrc.secrets` when it is readable. A missing file is fine. Flux does not install or manage this file.

For a new local file, copy `zsh/.zshrc.secrets.example` to `~/.zshrc.secrets`, then edit it locally as needed. The example contains no credential and makes no exports. Do not overwrite an existing secrets file or commit credentials. Repository copies named `.zshrc.secrets` at the root or under `zsh/` are ignored.

The revoked AI Gateway key was removed from the current shell configurations. Git history still contains it; this change does not rewrite history.
