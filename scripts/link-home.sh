#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_dir="$repo_root/home"
timestamp="$(date +%Y%m%d%H%M%S)"

if [[ ! -d "$source_dir" ]]; then
  echo "Missing $source_dir"
  exit 1
fi

find "$source_dir" -type f | while IFS= read -r source; do
  relative_path="${source#$source_dir/}"
  target="$HOME/$relative_path"

  mkdir -p "$(dirname "$target")"

  if [[ -L "$target" ]]; then
    current="$(readlink "$target")"
    if [[ "$current" == "$source" ]]; then
      echo "linked: $target"
      continue
    fi
    rm "$target"
  elif [[ -e "$target" ]]; then
    backup="$target.backup-$timestamp"
    echo "backup: $target -> $backup"
    mv "$target" "$backup"
  fi

  ln -s "$source" "$target"
  echo "link: $target -> $source"
done
