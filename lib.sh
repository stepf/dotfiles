# shellcheck shell=bash
# Every setup script sources this file. Route changes through link, ensure_dir,
# run or act, or --dry-run won't cover them; cheap idempotent commands may stay bare.

set -o pipefail
set -e

DRY_RUN=0
for _arg in "$@"; do
  case "$_arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    -h|--help) echo "usage: $0 [--dry-run]"; exit 0 ;;
    *) echo "$0: unknown argument: $_arg" >&2; exit 2 ;;
  esac
done
unset _arg

# Every output line is "<verb> <what>". The verbs are shell commands (symlink,
# mkdir, mv, rm, run) plus write, skip, warn and unchanged. In a dry run the
# verb of a change gets a "would " in front; unchanged, skip and warn print as usual.
# Each line is also counted in $SETUP_COUNTS, so the summary at the end covers all steps.
if [ -z "${SETUP_COUNTS:-}" ]; then
  SETUP_COUNTS="$(mktemp)"
  export SETUP_COUNTS
  trap '_summary $?' EXIT
fi

# Prints the summary only in the process that created $SETUP_COUNTS, and only on success.
_summary() {
  local rc="$1" changed unchanged skipped warned line
  [ "$rc" = 0 ] || { rm -f "$SETUP_COUNTS"; return; }
  changed="$(grep -c '^changed$' "$SETUP_COUNTS" || true)"
  unchanged="$(grep -c '^unchanged$' "$SETUP_COUNTS" || true)"
  skipped="$(grep -c '^skipped$' "$SETUP_COUNTS" || true)"
  warned="$(grep -c '^warned$' "$SETUP_COUNTS" || true)"
  rm -f "$SETUP_COUNTS"
  if [ "$DRY_RUN" = 1 ]; then line="dry run: would change $changed"; else line="done: $changed changed"; fi
  line="$line, $unchanged unchanged, $skipped skipped"
  [ "$warned" = 0 ] || line="$line, $warned warned"
  printf '\n%s\n' "$line"
}

# Shows $HOME as ~ so lines stay short and look the same on every machine.
_short() {
  local text="$1" home='~'
  printf '%s' "${text//"$HOME"/$home}"
}

log() {
  local kind
  case "$1" in
    unchanged) kind=unchanged ;;
    skip) kind=skipped ;;
    warn) kind=warned ;;
    *) kind=changed ;;
  esac
  echo "$kind" >> "$SETUP_COUNTS"
  printf '%-14s %s\n' "$1" "$(_short "$2")"
}
warn() { log warn "$*" >&2; }

# Starts the output of one step.
header() { printf '\n== %s ==\n' "$1"; }

# Logs a change, as "would <verb>" in a dry run. The caller does the change unless DRY_RUN is 1.
act() {
  if [ "$DRY_RUN" = 1 ]; then log "would $1" "$2"; else log "$1" "$2"; fi
}

is_macos() { [ "$(uname -s)" = "Darwin" ]; }

run() {
  act run "$*"
  if [ "$DRY_RUN" = 1 ]; then return 0; fi
  "$@"
}

ensure_dir() {
  if [ -d "$1" ]; then log unchanged "$1"; return 0; fi
  act mkdir "$1"
  if [ "$DRY_RUN" != 1 ]; then mkdir -p "$1"; fi
}

# ln -n replaces a link to a directory instead of creating a link inside it.
link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    log unchanged "$dst -> $src"
    return 0
  fi
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    act mv "$dst -> $dst.bak"
    if [ "$DRY_RUN" != 1 ]; then
      mv "$dst" "$dst.bak"
      warn "$dst was a real file or directory, moved to $dst.bak, merge it by hand"
    fi
  fi
  act symlink "$dst -> $src"
  if [ "$DRY_RUN" != 1 ]; then ln -sfn "$src" "$dst"; fi
}
