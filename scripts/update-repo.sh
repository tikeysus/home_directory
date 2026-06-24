#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
commit_changes=false
push_changes=false

usage() {
  cat <<'EOF'
Usage:
  scripts/update-repo.sh [--commit] [--push]

Refresh tracked environment snapshots, validate them, and show git status.

Options:
  --commit  Commit refreshed files if anything changed.
  --push    Push the current branch after a successful --commit.
  -h, --help
            Show this help.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --commit)
      commit_changes=true
      shift
      ;;
    --push)
      push_changes=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ "$push_changes" == true && "$commit_changes" != true ]]; then
  echo "--push requires --commit"
  exit 1
fi

cd "$repo_root"

run_check() {
  local description="$1"
  shift
  echo "check: $description"
  "$@"
}

validate_snapshots() {
  run_check "shell syntax" bash -n scripts/*.sh

  if command -v brew >/dev/null 2>&1 && [[ -f packages/Brewfile ]]; then
    run_check "Brewfile dependencies" brew bundle check --no-upgrade --file packages/Brewfile
  else
    echo "skip: Brewfile check needs brew and packages/Brewfile"
  fi

  if command -v plutil >/dev/null 2>&1 && [[ -f config/iterm2/com.googlecode.iterm2.plist ]]; then
    run_check "iTerm2 plist" plutil -lint config/iterm2/com.googlecode.iterm2.plist
  else
    echo "skip: iTerm2 plist check needs plutil and config/iterm2/com.googlecode.iterm2.plist"
  fi

  run_check "VS Code JSONC" python3 scripts/validate-jsonc.py \
    config/vscode/User/settings.json \
    config/vscode/User/keybindings.json
}

echo "Refreshing environment snapshots..."
"$repo_root/scripts/snapshot.sh"

echo
echo "Validating refreshed files..."
validate_snapshots

echo
echo "Git status:"
git status --short

if git diff --quiet && git diff --cached --quiet; then
  echo
  echo "No environment snapshot changes detected."
  exit 0
fi

echo
echo "Changed files:"
{
  git diff --name-only
  git diff --cached --name-only
  git ls-files --others --exclude-standard
} | sort -u

if [[ "$commit_changes" != true ]]; then
  cat <<'EOF'

Review the diff, then either commit manually or run:
  make snapshot-commit

To commit and push in one pass:
  make snapshot-push
EOF
  exit 0
fi

git add -A -- README.md Makefile scripts/update-repo.sh scripts/snapshot.sh scripts/validate-jsonc.py \
  packages/Brewfile packages/homebrew \
  packages/cargo/installed.txt packages/vscode/extensions.txt \
  config/vscode/User/settings.json config/vscode/User/keybindings.json \
  config/iterm2/com.googlecode.iterm2.plist \
  config/claude

if git diff --cached --quiet; then
  echo "No staged snapshot changes to commit."
  exit 0
fi

git commit -m "Refresh environment snapshot"

if [[ "$push_changes" == true ]]; then
  branch="$(git rev-parse --abbrev-ref HEAD)"
  git push origin "$branch"
fi
