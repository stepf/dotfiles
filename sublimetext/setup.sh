#!/usr/bin/env bash

set -o pipefail
set -e
set -x

SUBLIME_PATH="${HOME}/Library/Application Support/Sublime Text/Packages/User"

if [ -f "${SUBLIME_PATH}/Preferences.sublime-settings" ]; then
  mv "${SUBLIME_PATH}/Preferences.sublime-settings" "${SUBLIME_PATH}/Preferences.sublime-settings.old"
fi

if [ -d "${SUBLIME_PATH}" ]; then
  ln -s "$(pwd)/Preferences.sublime-settings" "${SUBLIME_PATH}/Preferences.sublime-settings"
fi
