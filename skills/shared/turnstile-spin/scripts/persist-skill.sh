#!/usr/bin/env bash

set -uo pipefail

PATH_ARG=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --path) PATH_ARG="$2"; shift 2 ;;
    *) echo "persist-skill: unknown arg $1" >&2; exit 2 ;;
  esac
done

: "${PATH_ARG:?--path required}"

TARGET_DIR=$(dirname "$PATH_ARG")
mkdir -p "$TARGET_DIR"

if ! npx --yes degit cloudflare/skills/skills/turnstile-spin "$TARGET_DIR" >/dev/null 2>&1; then
  echo "persist-skill: degit failed; cannot fetch cloudflare/skills/skills/turnstile-spin." >&2
  echo "persist-skill: ensure your network can reach github.com and try again, or install manually." >&2
  echo "{\"status\":\"error\",\"reason\":\"degit_failed\"}"
  exit 1
fi

if [ ! -f "$TARGET_DIR/SKILL.md" ]; then
  echo "persist-skill: bundle extracted but SKILL.md is missing at $TARGET_DIR/SKILL.md." >&2
  echo "{\"status\":\"error\",\"reason\":\"skill_missing\"}"
  exit 1
fi

if [ -d "$TARGET_DIR/scripts" ]; then
  chmod +x "$TARGET_DIR/scripts"/*.sh 2>/dev/null || true
fi

scripts_list=$(ls "$TARGET_DIR/scripts" 2>/dev/null | sed 's/.*/"&"/' | paste -sd, -)
echo "persist-skill: wrote bundle to $TARGET_DIR" >&2
echo "{\"status\":\"ok\",\"path\":\"$PATH_ARG\",\"bundle_root\":\"$TARGET_DIR\",\"scripts\":[$scripts_list]}"
exit 0
