#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/../lib.sh"

APPLICATION_PATHS=(
  "${HOME}/Library/Application Support/Code/User"
)

for APPLICATION in "${APPLICATION_PATHS[@]}"; do
  if [ -d "${APPLICATION}" ]; then
    link "${SCRIPT_DIR}/settings.json" "${APPLICATION}/settings.json"
  else
    log skip "${APPLICATION} (VSCode not installed yet)"
  fi
done

# The Brewfile here lists the VSCode extensions.
run brew bundle --file="${SCRIPT_DIR}/Brewfile" --no-upgrade
