#!/usr/bin/env bash

set -uo pipefail

NAME="${WORKER_NAME:-turnstile-siteverify}"
DEPLOY_DIR="/tmp/turnstile-siteverify-deploy"
while [[ $# -gt 0 ]]; do
  case $1 in
    --name)       NAME="$2"; shift 2 ;;
    --deploy-dir) DEPLOY_DIR="$2"; shift 2 ;;
    *) echo "worker-deploy: unknown arg $1" >&2; exit 2 ;;
  esac
done

: "${CLOUDFLARE_API_TOKEN:?CLOUDFLARE_API_TOKEN must be set}"
: "${WIDGET_SECRET:?WIDGET_SECRET must be set}"

deploy_log=$(mktemp)

deploy() {
  local target_name="$1"
  rm -rf "$DEPLOY_DIR"
  npx --yes degit cloudflare/skills/skills/turnstile-spin/templates/worker "$DEPLOY_DIR" >/dev/null 2>&1
  (cd "$DEPLOY_DIR" && npx wrangler deploy --name "$target_name") >"$deploy_log" 2>&1
}

if ! deploy "$NAME"; then
  if grep -q "script name already in use" "$deploy_log"; then
    NAME="${NAME}-$(openssl rand -hex 3 2>/dev/null || date +%s | tail -c 5)"
    echo "worker-deploy: name conflict; retrying as $NAME" >&2
    if ! deploy "$NAME"; then
      echo "worker-deploy: deploy failed even with new name" >&2
      cat "$deploy_log" >&2
      rm -f "$deploy_log"
      echo "{\"status\":\"error\",\"reason\":\"name_conflict_after_retry\"}"
      exit 1
    fi
  else
    cat "$deploy_log" >&2
    rm -f "$deploy_log"
    echo "{\"status\":\"error\",\"reason\":\"deploy_failed\"}"
    exit 1
  fi
fi

secret_log=$(mktemp)
set_secret() {
  echo "$WIDGET_SECRET" | (cd "$DEPLOY_DIR" && npx wrangler secret put TURNSTILE_SECRET_KEY --name "$NAME") >"$secret_log" 2>&1
}

if ! set_secret; then
  echo "worker-deploy: failed to set TURNSTILE_SECRET_KEY on $NAME" >&2
  cat "$secret_log" >&2
  detail=$(tail -3 "$secret_log" | tr '\n' ' ' | sed 's/"/\\"/g' | head -c 200)
  rm -f "$deploy_log" "$secret_log"
  echo "{\"status\":\"error\",\"reason\":\"set_secret_failed\",\"worker_name\":\"$NAME\",\"detail\":\"$detail\"}"
  exit 1
fi
rm -f "$secret_log"
sleep 5

worker_url=$(grep -oE 'https://[a-zA-Z0-9._-]+\.workers\.dev' "$deploy_log" | head -1)
if [ -z "$worker_url" ]; then
  worker_url=$(grep -oE 'https://[a-zA-Z0-9.-]+(/[^[:space:]]*)?' "$deploy_log" \
    | grep -v -E 'cloudflare\.com|workers-sdk|github\.com' \
    | head -1)
fi
rm -f "$deploy_log"

if [ -z "$worker_url" ]; then
  echo "worker-deploy: deployed but could not parse Worker URL from wrangler output" >&2
  echo "worker-deploy: ask the user for the URL printed by wrangler deploy and pass it to validate.sh manually" >&2
  echo "{\"status\":\"error\",\"reason\":\"url_parse_failed\",\"worker_name\":\"$NAME\"}"
  exit 1
fi

echo "{\"status\":\"ok\",\"worker_url\":\"$worker_url\",\"worker_name\":\"$NAME\"}"
