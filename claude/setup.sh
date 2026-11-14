#!/usr/bin/env bash
# Personal profile in ~/.claude, one more per directory in ~/clients (see README).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/../lib.sh"
CLAUDE_DIR="$HOME/.claude"

ensure_dir "$CLAUDE_DIR/output-styles"

# Claude Code writes this file in place, so /model and /config show up as a git diff.
SETTINGS="$CLAUDE_DIR/settings.json"
link "${SCRIPT_DIR}/settings.json" "$SETTINGS"   # a real file is kept as .bak by link()

# The statusLine key in settings.json points here.
link "${SCRIPT_DIR}/statusline.sh" "$CLAUDE_DIR/statusline.sh"

# One link per file, so styles created in the app stay local.
link_styles() {
  for STYLE in "${SCRIPT_DIR}"/output-styles/*.md; do
    link "$STYLE" "$1/output-styles/$(basename "$STYLE")"
  done
}
link_styles "$CLAUDE_DIR"

### Profiles for ~/clients/<name>, picked by the claude shim
# settings.json is a copy written once, not a link: a link would let /model there
# change the personal file. No defaultMode and no model on purpose, so it prompts
# in other people's code and never picks a model the account can't bill.
write_client_settings() {
  act write "$1"
  if [ "$DRY_RUN" = 1 ]; then return 0; fi
  cat > "$1" <<'JSON'
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
  "skipWorkflowUsageWarning": true,
  "tui": "fullscreen"
}
JSON
}

for CLIENT_DIR in "$HOME"/clients/*/; do
  [ -d "$CLIENT_DIR" ] || continue
  CLIENT="$(basename "$CLIENT_DIR")"
  PROFILE="$HOME/.claude-profiles/$CLIENT"

  ensure_dir "$PROFILE/output-styles"
  link_styles "$PROFILE"

  # statusLine points at ~/.claude on purpose, so statusline.local.sh applies to every profile.
  [ -e "$PROFILE/settings.json" ] || write_client_settings "$PROFILE/settings.json"
done

### Alternate profiles <name>-2 (claude2), mirrored from their base once Claude Code created them
# A settings.json without statusLine is the bare first-launch file and gets replaced.
# Plugins, MCP servers and connector logins are per account: run /mcp there.
for ALT in "$HOME"/.claude-profiles/*-[0-9]*/; do
  [ -d "$ALT" ] || continue
  ALT="${ALT%/}"
  BASE="${ALT%-*}"
  [ -d "$HOME/clients/$(basename "$BASE")" ] || continue

  ensure_dir "$ALT/output-styles"
  link_styles "$ALT"

  # Personal skills live in the base profile; the alternate links each one, because skills/synced is per account.
  for SK in "$BASE"/skills/*/; do
    SK="${SK%/}"
    [ "$(basename "$SK")" = synced ] && continue
    ensure_dir "$ALT/skills"
    link "$SK" "$ALT/skills/$(basename "$SK")"
  done

  if [ -f "$BASE/CLAUDE.md" ] && { [ ! -e "$ALT/CLAUDE.md" ] || [ -L "$ALT/CLAUDE.md" ]; }; then
    link "$BASE/CLAUDE.md" "$ALT/CLAUDE.md"
  fi

  if [ -f "$BASE/settings.json" ] && ! grep -q '"statusLine"' "$ALT/settings.json" 2>/dev/null; then
    [ -f "$ALT/settings.json" ] && run mv "$ALT/settings.json" "$ALT/settings.json.bak"
    run cp "$BASE/settings.json" "$ALT/settings.json"
  fi

  # Share history with the base profile; merging moves live files, so wait until no session runs.
  running=""
  for S in "$BASE"/sessions/*.json "$ALT"/sessions/*.json; do
    [ -f "$S" ] && kill -0 "$(basename "$S" .json)" 2>/dev/null && running=1
  done
  if [ -n "$running" ]; then
    warn "a $(basename "$BASE") session is running, close it and re-run to share history with $(basename "$ALT")"
    continue
  fi
  # The alternate's own copy stays as <name>.merged until you delete it by hand.
  for SHARED in projects file-history history.jsonl; do
    [ -L "$ALT/$SHARED" ] && continue
    case "$SHARED" in
      *.jsonl) touch "$BASE/$SHARED" ;;
      *) ensure_dir "$BASE/$SHARED" ;;
    esac
    if [ -d "$ALT/$SHARED" ]; then
      # -r without -l skips symlinks, i.e. the memory links into the base profile
      run rsync -r --times --ignore-existing "$ALT/$SHARED/" "$BASE/$SHARED/"
      run mv "$ALT/$SHARED" "$ALT/$SHARED.merged"
    elif [ -f "$ALT/$SHARED" ]; then
      act write "$BASE/$SHARED (append $ALT/$SHARED)"
      if [ "$DRY_RUN" != 1 ]; then
        cat "$ALT/$SHARED" >> "$BASE/$SHARED"
      fi
      run mv "$ALT/$SHARED" "$ALT/$SHARED.merged"
    fi
    link "$BASE/$SHARED" "$ALT/$SHARED"
  done
done
