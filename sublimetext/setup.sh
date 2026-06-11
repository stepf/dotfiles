#!/usr/bin/env bash

set -o pipefail
set -e
set -x

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

SUBLIME_PATH="${HOME}/Library/Application Support/Sublime Text/Packages/User"

if [ ! -d "${SUBLIME_PATH}" ]; then
  echo "Sublime Text not installed yet — skipping"
  exit 0
fi

ln -sf "${SCRIPT_DIR}/Preferences.sublime-settings" "${SUBLIME_PATH}/Preferences.sublime-settings"
