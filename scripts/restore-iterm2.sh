#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
plist="$repo_root/config/iterm2/com.googlecode.iterm2.plist"

if [[ ! -f "$plist" ]]; then
  echo "Missing $plist"
  exit 1
fi

defaults import com.googlecode.iterm2 "$plist"
killall cfprefsd >/dev/null 2>&1 || true
echo "Imported iTerm2 preferences."
