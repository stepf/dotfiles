#!/usr/bin/env bash

set -o pipefail
set -e
set -x

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

APPLICATION_PATHS=(
  "${HOME}/Library/Application Support/Cursor/User"
  "${HOME}/Library/Application Support/Code/User"
)

for APPLICATION in "${APPLICATION_PATHS[@]}"; do
  if [ -d "${APPLICATION}" ]; then
    ln -sf "${SCRIPT_DIR}/settings.json" "${APPLICATION}/settings.json"
  fi
done

# Install extensions (idempotent — already installed extensions are skipped)
brew bundle --file="${SCRIPT_DIR}/Brewfile" --no-upgrade
