# shellcheck shell=bash
# Every setup script sources this file. Route changes through link, ensure_dir
# or run, or --dry-run won't cover them; cheap idempotent commands may stay bare.

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

# Verbs in use: ok, link, mkdir, run, would (dry run), skip, warn.
log()  { printf '%-5s %s\n' "$1" "$2"; }
warn() { printf '%-5s %s\n' "warn" "$*" >&2; }

is_macos() { [ "$(uname -s)" = "Darwin" ]; }

run() {
  if [ "$DRY_RUN" = 1 ]; then
    log would "$*"
    return 0
  fi
  log run "$*"
  "$@"
}

ensure_dir() {
  [ -d "$1" ] && return 0
  if [ "$DRY_RUN" = 1 ]; then log would "mkdir -p $1"; return 0; fi
  log mkdir "$1"
  mkdir -p "$1"
}

# ln -n replaces a link to a directory instead of creating a link inside it.
link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    log ok "$dst"
    return 0
  fi
  if [ "$DRY_RUN" = 1 ]; then log would "ln -sfn $src $dst"; return 0; fi
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak"
    warn "$dst was a real file or directory, moved to $dst.bak, merge it by hand"
  fi
  log link "$dst -> $src"
  ln -sfn "$src" "$dst"
}
