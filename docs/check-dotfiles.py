#!/usr/bin/env python3
"""Check repository mappings, submodules, and tracked symlinks without installing."""

import configparser
import pathlib
import subprocess
import tomllib

ROOT = pathlib.Path(__file__).resolve().parents[1]
errors = []
config = tomllib.loads((ROOT / "config.toml").read_text())

for tool, entries in config["tools"].items():
    for kind in ("files", "folders"):
        for entry in entries.get(kind, []):
            source = ROOT / entry["repo"]
            if not source.exists():
                errors.append(f"{tool}: missing source {entry['repo']}")
            elif kind == "folders" and not source.is_dir():
                errors.append(f"{tool}: folder source is not a directory: {entry['repo']}")
            if pathlib.Path(entry["dest"]).is_absolute():
                errors.append(f"{tool}: destination must be relative to home: {entry['dest']}")


def tracked_entries(repo):
    result = subprocess.run(
        ["git", "ls-files", "--stage", "-z"], cwd=repo, check=True, capture_output=True
    )
    for record in result.stdout.decode().split("\0"):
        if record:
            metadata, path = record.split("\t", 1)
            yield metadata.split()[0], path


gitlinks = set()
for mode, path in tracked_entries(ROOT):
    if mode == "160000":
        gitlinks.add(path)
        repo = ROOT / path
        if not (repo / ".git").exists():
            errors.append(f"Uninitialized submodule: {path}")
            continue
        entries = tracked_entries(repo)
    else:
        repo = ROOT
        entries = [(mode, path)]
    for entry_mode, entry_path in entries:
        if entry_mode == "120000" and pathlib.Path(entry_path).name != "node_modules":
            link = repo / entry_path
            if not link.is_symlink() or not link.exists():
                errors.append(f"Missing or broken symlink: {link.relative_to(ROOT)}")

modules = configparser.ConfigParser()
modules.read(ROOT / ".gitmodules")
declared = {modules[section]["path"] for section in modules.sections()}
for path in sorted(declared ^ gitlinks):
    errors.append(f"Submodule declaration and Git index disagree: {path}")

if errors:
    raise SystemExit("\n".join(errors))
print("Dotfiles mappings, submodules, and tracked symlinks are valid.")
