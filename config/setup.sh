#!/usr/bin/env bash

set -o pipefail
set -e
set -x

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

### Symlink starship config
mkdir -p "$HOME/.config/"
ln -sf "${SCRIPT_DIR}/starship.toml" "$HOME/.config/starship.toml"

### Symlink ghostty config
mkdir -p "$HOME/.config/ghostty/"
ln -sf "${SCRIPT_DIR}/ghostty" "$HOME/.config/ghostty/config"
