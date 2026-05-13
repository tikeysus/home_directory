#!/usr/bin/env bash
set -euo pipefail

zsh_dir="${ZSH:-$HOME/.oh-my-zsh}"
custom_dir="${ZSH_CUSTOM:-$zsh_dir/custom}"

if [[ ! -d "$zsh_dir" ]]; then
  if ! command -v git >/dev/null 2>&1; then
    echo "git is required to install Oh My Zsh."
    exit 1
  fi

  git clone https://github.com/ohmyzsh/ohmyzsh.git "$zsh_dir"
fi

mkdir -p "$custom_dir/plugins"

install_plugin() {
  local name="$1"
  local url="$2"
  local target="$custom_dir/plugins/$name"

  if [[ -d "$target/.git" ]]; then
    git -C "$target" pull --ff-only
  elif [[ -d "$target" ]]; then
    echo "Skipping $name: $target exists but is not a git checkout."
  else
    git clone "$url" "$target"
  fi
}

install_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git
