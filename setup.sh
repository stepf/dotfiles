#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/lib.sh"

# macos runs first, because home/setup.sh skips its fallbacks once Homebrew is there.
if is_macos; then
  STEPS=(macos home config claude sublimetext vscode)
else
  STEPS=(home config claude)
fi

for STEP in "${STEPS[@]}"; do
  header "$STEP"
  "${SCRIPT_DIR}/${STEP}/setup.sh" "$@"
done
