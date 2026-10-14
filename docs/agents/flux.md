# Flux dotfiles workflow

Read this document before changing dotfiles mappings, importing live configuration, applying links, or modifying the Codex/Pi setup.

Flux manages configuration stored in `~/.dotfiles` and links it into application paths. Its configuration is `~/.dotfiles/config.toml`; target this repository explicitly with:

```sh
flux --config ~/.dotfiles/config.toml …
```

## Initial setup

For a new checkout, clone the repository with its submodules:

```sh
git clone --recurse-submodules <repository-url> ~/.dotfiles
```

For an existing checkout, initialize its submodules:

```sh
git -C ~/.dotfiles submodule update --init --recursive
```

Install [Flux](https://forgejo.disilla.org/chrono/flux), then follow the workflow below to validate mappings, preview links, and apply the setup. Review the preview before applying. Use `--force` only when repository content should replace existing local configuration.

## Workflow

1. Inspect both repository and installation state:

   ```sh
   git -C ~/.dotfiles status --short
   flux --config ~/.dotfiles/config.toml status
   ```

2. Identify the source before editing. Use `readlink` when a destination may be linked, then check `config.toml` to resolve the repository source. Edit that source, not a copied destination. If the source remains unclear, inspect the mapping and link state before editing.

3. When mappings or installation state could change, preview the complete operation and inspect its diff:

   ```sh
   flux --config ~/.dotfiles/config.toml apply --dry-run --diff
   ```

4. Apply only when the task requires installation changes. A normal apply may conflict with existing files. Use `--force` only when repository content is intentionally replacing those destinations; use `--yes` only when skipping prompts is intentional.

5. Validate the result:

   ```sh
   python3 ~/.dotfiles/docs/check-dotfiles.py
   git -C ~/.dotfiles diff --check
   flux --config ~/.dotfiles/config.toml status
   flux --config ~/.dotfiles/config.toml doctor
   ```

   For mapping changes, also confirm the mapped repository source path appears in `flux --config ~/.dotfiles/config.toml ls-files`. After applying, confirm destinations with `readlink` or `ls -ld`. Completion means the repository is valid and every intended destination is either already linked or was applied successfully.

## Adding and changing mappings

The root `config.toml` maps repository paths to destinations relative to `$HOME`. Existing paths should be edited in the repository. Add or adjust a mapping only when the destination relationship itself changes.

To register existing repository content without importing a live destination:

```sh
flux --config ~/.dotfiles/config.toml add <tool> <repo-path> \
  --from-repo --dest <home-relative-destination> --dry-run
```

Without `--from-repo`, `flux add` imports the supplied live source. Preserve existing profile and platform conditions rather than assuming a mapping applies on every machine.

A folder mapping owns the whole mapped directory. Account for destination-only content before replacing one. Codex's `.system` directory is local and ignored; keep it out of repository mappings.

## Codex and Pi layout

Codex has platform-specific sources:

- Linux: `codex/config.toml`
- macOS: `codex/config.macos.toml`

Flux links the matching source to `~/.codex/config.toml`. Keep application paths, plugin versions, computer-use settings, and OS-specific MCP configuration in the corresponding platform file. Apply portable preferences to both. The desktop app may alter its linked source, so inspect its diff rather than copying one platform file over the other.

Skills have a shared store and harness-specific views:

```text
skills/shared/   shared implementations and references
codex/skills/    Codex view, linked from ~/.codex/skills
pi/skills/       Pi view, exposed through the Pi setup
```

Identical skills link to `skills/shared`. Harness-specific entrypoints stay in the appropriate view while common files remain shared. Check `readlink` before editing. Preserve each harness's invocation rules, delegation tools, and model configuration.

Pi's setup is the `pi/agent` Git submodule. `~/.pi/agent` links to it, and its tracked `skills` link resolves to the Pi skills view. Pi credentials, sessions, settings, and dependencies are local ignored state; preserve them when replacing an installation.

For a fresh setup, initialize the submodule, preview and apply Flux, then run `bun install --frozen-lockfile` in `~/.pi/agent`. To update the pinned setup, commit and push changes inside `pi/agent` first, then commit the new submodule pointer in the parent dotfiles repository.

The poteto-mode helpers keep generated dependencies under `skills/shared/poteto-mode/scripts`. Install them there with `bun install --frozen-lockfile`; keep `node_modules` out of Git.

## Committing and publishing

`flux --config ~/.dotfiles/config.toml commit` synchronizes every destination tracked by this Flux configuration before committing, so it can import unrelated local application changes. Inspect `flux --config ~/.dotfiles/config.toml status` and the Git diff first. For a selected-file commit, use explicit `git add -- <paths>` and `git commit` instead.

Push only when publication is requested, using `flux --config ~/.dotfiles/config.toml push` or `git push`. A successful commit does not prove installation state is correct; report repository and installation outcomes separately.
