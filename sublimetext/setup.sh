#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/../lib.sh"

SUBLIME_PATH="${HOME}/Library/Application Support/Sublime Text/Packages/User"

if [ ! -d "${SUBLIME_PATH}" ]; then
  log skip "Sublime Text not installed yet"
  exit 0
fi

link "${SCRIPT_DIR}/Preferences.sublime-settings" "${SUBLIME_PATH}/Preferences.sublime-settings"
link "${SCRIPT_DIR}/Markdown.sublime-settings" "${SUBLIME_PATH}/Markdown.sublime-settings"
