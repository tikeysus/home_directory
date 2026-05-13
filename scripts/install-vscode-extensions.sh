#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
extensions_file="$repo_root/packages/vscode/extensions.txt"

if ! command -v code >/dev/null 2>&1; then
  echo "VS Code CLI 'code' is not installed or not on PATH."
  exit 1
fi

while IFS= read -r extension; do
  [[ -z "$extension" || "$extension" == \#* ]] && continue
  code --install-extension "$extension"
done < "$extensions_file"
