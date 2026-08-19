#!/usr/bin/env bash

set -o pipefail
set -e
set -x

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR/output-styles"

### settings.json
# Claude Code rewrites this file itself (/config, /model, plugin installs). It
# writes in place, so the symlink survives and the edits land as a git diff. If
# a future version replaces the link with a regular file, keep that file rather
# than dropping the settings it holds.
SETTINGS="$CLAUDE_DIR/settings.json"
if [ -f "$SETTINGS" ] && [ ! -L "$SETTINGS" ]; then
  mv "$SETTINGS" "${SETTINGS}.bak"
  set +x
  echo "⚠️  ${SETTINGS} was a real file, moved to ${SETTINGS}.bak — merge it by hand"
  set -x
fi
ln -sf "${SCRIPT_DIR}/settings.json" "$SETTINGS"

### Statusline (referenced by the statusLine key in settings.json)
ln -sf "${SCRIPT_DIR}/statusline.sh" "$CLAUDE_DIR/statusline.sh"

### Output styles, one link per file so styles created in the app stay untouched
for STYLE in "${SCRIPT_DIR}"/output-styles/*.md; do
  ln -sf "$STYLE" "$CLAUDE_DIR/output-styles/$(basename "$STYLE")"
done
