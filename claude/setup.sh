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

### Client profiles
# The claude() function in ~/.zsh_functions points CLAUDE_CONFIG_DIR at
# ~/.claude-profiles/<client> under ~/clients/<client>, which relocates the whole
# config directory — credentials, history and settings alike. Without the loop
# below a client session would start with none of the settings above.
#
# The client settings.json is generated, not symlinked: Claude Code writes to it,
# so a shared link would let /model in a client session rewrite the personal
# config. It is written once and then left alone, so per-client changes stick
# across re-runs.
#
# Deliberately narrower than the personal file. No defaultMode, so edits and
# commands prompt in someone else's codebase; no model pin, so a client login on
# another plan is not forced onto a model it cannot bill. The version-cleanup
# hook is kept because the binaries it prunes are shared across all profiles, and
# in a client-heavy week the personal profile may not start often enough to run it.
#
# The client name is read from the directory at runtime and never written to this
# repo, which is public.
for CLIENT_DIR in "$HOME"/clients/*/; do
  [ -d "$CLIENT_DIR" ] || continue
  CLIENT="$(basename "$CLIENT_DIR")"
  PROFILE="$HOME/.claude-profiles/$CLIENT"

  mkdir -p "$PROFILE/output-styles"
  for STYLE in "${SCRIPT_DIR}"/output-styles/*.md; do
    ln -sf "$STYLE" "$PROFILE/output-styles/$(basename "$STYLE")"
  done

  # statusline.sh is shared from the personal directory on purpose — one script,
  # and its machine-local extras in ~/.claude/statusline.local.sh apply everywhere.
  if [ ! -e "$PROFILE/settings.json" ]; then
    cat > "$PROFILE/settings.json" <<'JSON'
{
  "outputStyle": "Plain language",
  "effortLevel": "high",
  "theme": "auto",
  "attribution": {
    "commit": "",
    "pr": ""
  },
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  },
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "cur=\"$(readlink -f \"$HOME/.local/bin/claude\" 2>/dev/null)\"; case \"$cur\" in \"$HOME/.local/share/claude/versions/\"*) [ -f \"$cur\" ] && find \"$HOME/.local/share/claude/versions\" -maxdepth 1 -type f ! -name \"${cur##*/}\" -delete 2>/dev/null;; esac",
            "async": true
          }
        ]
      }
    ]
  },
  "skipWorkflowUsageWarning": true,
  "tui": "fullscreen"
}
JSON
  fi
done
