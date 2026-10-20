# Ellie's Dotfiles

A dotfiles repository managed by [Flux](https://forgejo.disilla.org/chrono/flux), my Rust CLI for linking repository files into application paths under my home directory.

## Overview

The root `config.toml` maps application configuration and agent skills to paths under my home directory. Those paths link to files in this repository, so editing a linked file changes the repository copy. Git syncs repository changes across my machines.

See [the agent guide](docs/agents/flux.md) for mapping examples, commands, installation behavior, and verification.