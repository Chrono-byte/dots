#!/bin/sh
set -eu
umask 077

if [ "$(uname -s)" != Darwin ]; then
  echo "This script requires macOS." >&2
  exit 1
fi
if [ "$#" -gt 1 ]; then
  echo "Usage: sh ~/.dotfiles/scripts/setup-ssh-keychain.sh [private-key-path]" >&2
  exit 1
fi

key_path=${1:-"$HOME/.ssh/id_ed25519"}
case "$key_path" in
  /*) ;;
  *) key_path="$PWD/$key_path" ;;
esac
if [ ! -f "$key_path" ]; then
  echo "Private key not found: $key_path" >&2
  exit 1
fi
case "$key_path" in
  *'"'*|*'%'*|*'\'*|*'
'*)
    echo "The key path cannot contain quotes, percent signs, backslashes, or newlines." >&2
    exit 1
    ;;
esac

mkdir -p "$HOME/.ssh"
config_path="$HOME/.ssh/config"
config_tmp=$(mktemp "$HOME/.ssh/keychain-config.XXXXXX")
trap 'rm -f "$config_tmp"' EXIT HUP INT TERM

{
  echo '# BEGIN autorole SSH Keychain'
  echo 'Host github.com forgejo.disilla.org'
  echo '  AddKeysToAgent yes'
  echo '  UseKeychain yes'
  printf '  IdentityFile "%s"\n' "$key_path"
  echo '# END autorole SSH Keychain'
  echo 'Host *'
  if [ -f "$config_path" ]; then
    awk '
      $0 == "# BEGIN autorole SSH Keychain" { skip = 1; next }
      $0 == "# END autorole SSH Keychain" {
        skip = 0
        getline
        if ($0 != "Host *") print
        next
      }
      !skip { print }
    ' "$config_path"
  fi
} > "$config_tmp"

/usr/bin/ssh -G -F "$config_tmp" git@forgejo.disilla.org >/dev/null
/usr/bin/ssh-add --apple-use-keychain "$key_path"

if [ -f "$config_path" ] && ! cmp -s "$config_path" "$config_tmp"; then
  backup_path=$(mktemp "$HOME/.ssh/config.backup.XXXXXX")
  cp -p "$config_path" "$backup_path"
  printf 'Backed up SSH configuration to %s\n' "$backup_path"
fi
cat "$config_tmp" > "$config_path"
echo 'Keychain configured for GitHub and Forgejo.'
echo 'Verify with: ssh -T git@forgejo.disilla.org'
