#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if command -v brew >/dev/null 2>&1; then
  brew bundle dump --file="$repo_root/packages/Brewfile" --force --describe
fi

if command -v code >/dev/null 2>&1; then
  code --list-extensions | sort > "$repo_root/packages/vscode/extensions.txt"
fi

if command -v npm >/dev/null 2>&1; then
  npm list -g --depth=0 --parseable |
    sed '1d; s#.*/node_modules/##' |
    sort > "$repo_root/packages/npm/global-packages.txt"
fi

if command -v cargo >/dev/null 2>&1; then
  cargo install --list > "$repo_root/packages/cargo/installed.txt"
fi
