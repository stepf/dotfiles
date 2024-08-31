#!/usr/bin/env bash

set -o pipefail
set -e
set -x

APPLICATION_PATHS=(
  "${HOME}/Library/Application Support/Cursor/User"
  "${HOME}/Library/Application Support/Code/User"
)

for APPLICATION in "${APPLICATION_PATHS[@]}"; do
  if [ -f "${APPLICATION}/settings.json" ]; then
    mv "${APPLICATION}/settings.json" "${APPLICATION}/settings.json.old"
  fi

  if [ -d "${APPLICATION}" ]; then
    ln -s "$(pwd)/settings.json" "${APPLICATION}/settings.json"
  fi
done
