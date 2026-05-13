#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
timestamp="$(date +%Y%m%d%H%M%S)"

link_file() {
  local source="$1"
  local target="$2"

  if [[ ! -f "$source" ]]; then
    echo "skip missing: $source"
    return
  fi

  mkdir -p "$(dirname "$target")"

  if [[ -L "$target" ]]; then
    local current
    current="$(readlink "$target")"
    if [[ "$current" == "$source" ]]; then
      echo "linked: $target"
      return
    fi
    rm "$target"
  elif [[ -e "$target" ]]; then
    local backup="$target.backup-$timestamp"
    echo "backup: $target -> $backup"
    mv "$target" "$backup"
  fi

  ln -s "$source" "$target"
  echo "link: $target -> $source"
}

vscode_user_dir="$HOME/Library/Application Support/Code/User"
link_file "$repo_root/config/vscode/User/settings.json" "$vscode_user_dir/settings.json"
link_file "$repo_root/config/vscode/User/keybindings.json" "$vscode_user_dir/keybindings.json"
