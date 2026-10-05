# Flux in this repository

Flux is Ellie's Rust CLI for managing dotfiles through a Git repository and symlinks. The repository stores the configuration; Flux maps those paths to the places applications read under the user's home directory. Once a destination is linked, editing it also edits the repository file. Git records those changes and shares them between machines.

The CLI is `flux`. Its source repository is [chrono/flux](https://forgejo.disilla.org/chrono/flux). A local checkout, when present, is at `~/Dev/flux`. This document describes how to work on the dotfiles repository, rather than how to develop Flux itself.

## Configuration and mappings

The root `config.toml` is Flux's configuration. It selects the repository path, current profile, symlink resolution, and each tool's mappings. Use `flux --config ~/.dotfiles/config.toml …` to target this repository explicitly.

Each `[tools.<name>]` section groups configuration for an application or tool:

```toml
[tools.codex]
files = [
  { repo = "codex/config.toml", dest = ".codex/config.toml" },
  { repo = "codex/AGENTS.md", dest = ".codex/AGENTS.md" },
]
folders = [{ repo = "codex/skills", dest = ".codex/skills" }]
```

`repo` is relative to the dotfiles repository. `dest` is relative to the user's home directory. `files` tracks individual files; `folders` tracks a whole directory. The skills mapping covers new skills without requiring another Flux entry for every file.

Git tracking and Flux tracking are separate. Committing a file makes it available in the repository. Adding a mapping tells Flux where to install it. A mapping does not make an existing destination a symlink until it is applied.

Profiles and platform conditions can select different entries for different machines. Preserve existing selections when editing a mapping. Read the current configuration instead of assuming every entry applies on every host.

## Routine work

Start with `git status --short` and `flux status` to see repository changes and installation state. Edit the repository copy of the configuration being changed. For example, shell settings live under `zsh/`, Codex settings under `codex/`, and the tool mappings in the root `config.toml`.

For an existing repository path, add or adjust its mapping in `config.toml`. Flux can also register an existing directory:

```sh
flux --config ~/.dotfiles/config.toml add codex codex/skills \
  --from-repo --dest .codex/skills --dry-run
```

Use this when adding a mapping, not when the mapping already exists. `--from-repo` registers repository content instead of importing a live configuration file. Without it, `flux add` imports the supplied source and registers its destination.

Preview installation changes with:

```sh
flux --config ~/.dotfiles/config.toml apply --dry-run --diff
```

Read the operations and differences before applying. A normal apply can encounter conflicts with existing local files. `--force` chooses repository content and replaces destinations that are not already the correct links; `--yes` skips prompts. Use these options only when that behavior is intended by the task.

A folder mapping covers the entire directory. Before replacing `~/.codex/skills`, account for destination-only skills and Codex's `.system` directory. The repository's skill snapshot need not contain everything installed on the current machine. Preserve local-only content before replacing a destination folder.

## Commands worth knowing

| Command | Purpose |
| --- | --- |
| `flux ls-files` | List paths registered with Flux for the selected profile. |
| `flux status` | Inspect Git and installation state. |
| `flux diff` | Compare repository content with its destinations. |
| `flux doctor` | Check configuration and installation health. |
| `flux apply --dry-run --diff` | Preview installation operations and differences. |
| `flux history` | Inspect Flux's operation history. |
| `flux remote check` | Report when the current branch differs from its remote; stay quiet when the remote is unreachable. |
| `flux commit` | Synchronize tracked destinations and commit repository changes. |

For a task that should commit only selected files, use explicit `git add -- <paths>` and `git commit`. `flux commit` also synchronizes tracked destinations, which can bring additional local configuration into the repository. Check its scope before using it. Push with `git push` or `flux push` when the user requested publication.

## Verification

After changing a mapping, parse the TOML and confirm the intended path appears in `flux ls-files`. Use a dry run when the task involves installation. After changing content, run checks relevant to that tool and `git diff --check`. The dotfiles repository currently has no general lint or format command.

After applying, inspect the destination with `ls -ld` or `readlink` and check `flux status`. Successful Git commits and successful installation are separate outcomes; report which one was completed.
