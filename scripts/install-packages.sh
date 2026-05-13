#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if command -v brew >/dev/null 2>&1 && [[ -f "$repo_root/packages/Brewfile" ]]; then
  brew bundle --file "$repo_root/packages/Brewfile"
else
  echo "Skipping Homebrew packages: brew or packages/Brewfile missing."
fi

if command -v npm >/dev/null 2>&1 && [[ -f "$repo_root/packages/npm/global-packages.txt" ]]; then
  while IFS= read -r package; do
    [[ -z "$package" || "$package" == \#* ]] && continue
    npm install -g "$package"
  done < "$repo_root/packages/npm/global-packages.txt"
fi

echo "Cargo-installed tools are recorded in packages/cargo/installed.txt."
echo "Install them manually with cargo install as needed."
