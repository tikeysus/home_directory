#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if command -v brew >/dev/null 2>&1; then
  mkdir -p "$repo_root/packages/homebrew"
  brew bundle dump --file="$repo_root/packages/Brewfile" --force --describe
  brew tap > "$repo_root/packages/homebrew/taps.txt"
  brew list --formula --versions | sort > "$repo_root/packages/homebrew/formulae.txt"
  brew list --cask --versions | sort > "$repo_root/packages/homebrew/casks.txt"
  brew leaves | sort > "$repo_root/packages/homebrew/leaves.txt"
  brew services list > "$repo_root/packages/homebrew/services.txt"
  brew config > "$repo_root/packages/homebrew/config.txt"
fi

if command -v code >/dev/null 2>&1; then
  code --list-extensions | sort > "$repo_root/packages/vscode/extensions.txt"
fi

if command -v npm >/dev/null 2>&1; then
  npm list -g --depth=0 --json |
    node -e '
      let data = "";
      process.stdin.on("data", chunk => data += chunk);
      process.stdin.on("end", () => {
        const parsed = JSON.parse(data);
        const deps = parsed.dependencies || {};
        Object.keys(deps).sort().forEach(name => {
          const version = deps[name] && deps[name].version;
          console.log(version ? `${name}@${version}` : name);
        });
      });
    ' > "$repo_root/packages/npm/global-packages.txt"
fi

if command -v cargo >/dev/null 2>&1; then
  cargo install --list > "$repo_root/packages/cargo/installed.txt"
fi
