#!/usr/bin/env bash
# config/ mirrors ~/.config file by file.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/../lib.sh"

ensure_dir "$HOME/.config"
for entry in "${SCRIPT_DIR}"/*; do
  name="$(basename "$entry")"
  [[ "$name" == "setup.sh" ]] && continue
  if [[ -d "$entry" ]]; then
    ensure_dir "$HOME/.config/$name"
    for f in "$entry"/*; do
      link "$f" "$HOME/.config/$name/$(basename "$f")"
    done
  else
    link "$entry" "$HOME/.config/$name"
  fi
done

# These files are machine-local and never committed. Without scrub.sed the email
# filter fails every commit; local.gitconfig holds identity and URL rewrites.
touch "$HOME/.config/git/scrub.sed"
if [[ ! -f "$HOME/.config/git/local.gitconfig" ]]; then
  if [[ "$DRY_RUN" = 1 ]]; then
    log would "write $HOME/.config/git/local.gitconfig"
  else
    log run "write $HOME/.config/git/local.gitconfig"
    printf '[user]\n  email = 4513275+stepf@users.noreply.github.com\n' \
      > "$HOME/.config/git/local.gitconfig"
  fi
fi

# This activates .githooks/pre-commit for this repo.
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
if [[ "$(git -C "$REPO_DIR" config --get core.hooksPath)" != ".githooks" ]]; then
  git -C "$REPO_DIR" config core.hooksPath .githooks
fi
