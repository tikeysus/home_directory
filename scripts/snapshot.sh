#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
vscode_user_dir="$HOME/Library/Application Support/Code/User"
iterm_plist="$repo_root/config/iterm2/com.googlecode.iterm2.plist"

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

if [[ -f "$vscode_user_dir/settings.json" ]]; then
  cp "$vscode_user_dir/settings.json" "$repo_root/config/vscode/User/settings.json"
fi

if [[ -f "$vscode_user_dir/keybindings.json" ]]; then
  cp "$vscode_user_dir/keybindings.json" "$repo_root/config/vscode/User/keybindings.json"
fi

if command -v defaults >/dev/null 2>&1; then
  mkdir -p "$(dirname "$iterm_plist")"
  if defaults export com.googlecode.iterm2 "$iterm_plist" >/dev/null 2>&1; then
    plutil -convert xml1 "$iterm_plist"
  fi
fi

if command -v cargo >/dev/null 2>&1; then
  cargo install --list > "$repo_root/packages/cargo/installed.txt"
fi

claude_dir="$HOME/.claude"
claude_dest="$repo_root/config/claude"
if [[ -d "$claude_dir" ]]; then
  mkdir -p "$claude_dest/hooks"
  for f in CLAUDE.md settings.json settings.local.json keybindings.json; do
    [[ -f "$claude_dir/$f" ]] && cp "$claude_dir/$f" "$claude_dest/$f"
  done
  for f in "$claude_dir/hooks/"*.js; do
    [[ -f "$f" ]] && cp "$f" "$claude_dest/hooks/$(basename "$f")"
  done
fi
