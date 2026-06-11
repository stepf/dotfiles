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
