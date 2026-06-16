#!/usr/bin/env bash

set -o pipefail
set -e
set -x

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

### Symlink dotfiles to home directory
for file in "${SCRIPT_DIR}"/*; do
  name="$(basename "$file")"
  [[ "$name" == "setup.sh" ]] && continue
  ln -sf "$file" "$HOME/.$name"
done

### User-local clones for systems without Homebrew (macOS installs these via brew).
### Skipped entirely when brew is present.
if ! command -v brew >/dev/null 2>&1; then
  # zsh-autosuggestions (sourced from .zsh_conf)
  ZSH_AUTOSUGGESTIONS_DIR="$HOME/.zsh/zsh-autosuggestions"
  if [[ ! -d "$ZSH_AUTOSUGGESTIONS_DIR" ]]; then
    git clone --depth 1 \
      https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS_DIR"
  fi

  # z (rupa) jump-around tool (sourced from .zshrc)
  Z_DIR="$HOME/.zsh/z"
  if [[ ! -d "$Z_DIR" ]]; then
    git clone --depth 1 https://github.com/rupa/z "$Z_DIR"
  fi
fi
