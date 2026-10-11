#!/usr/bin/env bash

set -uo pipefail

while [[ $# -gt 0 ]]; do
  case $1 in
    --account-id) ACCOUNT_ID="$2"; shift 2 ;;
    --sitekey)    SITEKEY="$2"; shift 2 ;;
    *) echo "fetch-secret: unknown arg $1" >&2; exit 2 ;;
  esac
done

: "${CLOUDFLARE_API_TOKEN:?CLOUDFLARE_API_TOKEN must be set}"
: "${ACCOUNT_ID:?--account-id required}"
: "${SITEKEY:?--sitekey required}"

tmp=$(mktemp)
http_code=$(curl -sS -w "%{http_code}" -o "$tmp" \
  "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/challenges/widgets/$SITEKEY" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" 2>/dev/null || echo "000")
body=$(cat "$tmp"); rm -f "$tmp"

if [ "$http_code" = "200" ]; then
  secret=$(echo "$body" | (jq -r '.result.secret' 2>/dev/null || python3 -c "import sys,json; print(json.load(sys.stdin)['result']['secret'])"))
  clearance=$(echo "$body" | (jq -r '.result.clearance_level // "no_clearance"' 2>/dev/null || python3 -c "import sys,json; print(json.load(sys.stdin)['result'].get('clearance_level','no_clearance'))"))
  domains=$(echo "$body" | (jq -c '.result.domains // []' 2>/dev/null || python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin)['result'].get('domains',[])))"))
  if [ -n "$secret" ] && [ "$secret" != "null" ]; then
    echo "{\"status\":\"ok\",\"secret\":\"$secret\",\"clearance_level\":\"$clearance\",\"domains\":$domains}"
    exit 0
  fi
fi

if [ "$http_code" = "403" ]; then
  code=$(echo "$body" | (jq -r '.errors[0].code // 0' 2>/dev/null || echo "0"))
  if [ "$code" = "10000" ]; then
    echo "fetch-secret: token can edit Turnstile widgets but cannot read this one's secret." >&2
    echo "fetch-secret: add Account.Turnstile:Read to the token, or fall back to user paste." >&2
    echo "{\"status\":\"missing_read_scope\",\"detail\":\"token lacks Account.Turnstile:Read\"}"
    exit 1
  fi
fi

echo "fetch-secret: widget lookup failed (HTTP $http_code)." >&2
echo "{\"status\":\"error\",\"reason\":\"widget_not_found\",\"http_code\":$http_code}"
exit 1
