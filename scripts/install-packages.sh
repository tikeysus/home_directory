#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

ensure_homebrew

if command -v brew >/dev/null 2>&1 && [[ -f "$repo_root/packages/Brewfile" ]]; then
  brew bundle --file "$repo_root/packages/Brewfile"
else
  echo "Skipping Homebrew packages: brew or packages/Brewfile missing."
fi

if command -v cargo >/dev/null 2>&1 && [[ -f "$repo_root/packages/cargo/installed.txt" ]]; then
  while IFS= read -r line; do
    [[ "$line" =~ ^([^[:space:]]+)[[:space:]]v([^:]+):$ ]] || continue
    cargo install "${BASH_REMATCH[1]}" --version "${BASH_REMATCH[2]}"
  done < "$repo_root/packages/cargo/installed.txt"
fi
