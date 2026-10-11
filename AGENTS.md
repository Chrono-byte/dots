# Dotfiles

This repository is managed by Flux. Read [docs/agents/flux.md](docs/agents/flux.md) before changing tracked paths, importing local configuration, or applying the repository to a machine.

The root `config.toml` configures Flux. `codex/config.toml` configures Codex on Linux; `codex/config.macos.toml` configures Codex on macOS. Flux selects by OS. Keep platform paths and app-managed runtime settings in the matching file; update both for shared preferences.
