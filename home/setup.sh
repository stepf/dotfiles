#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/../lib.sh"

# Each home/<name> becomes ~/.<name>, directories included.
for file in "${SCRIPT_DIR}"/*; do
  name="$(basename "$file")"
  [[ "$name" == "setup.sh" ]] && continue
  link "$file" "$HOME/.$name"
done

# Remove links into home/ whose file was renamed or moved.
for dst in "$HOME"/.*; do
  [[ -L "$dst" && ! -e "$dst" && "$(readlink "$dst")" == "${SCRIPT_DIR}/"* ]] || continue
  if [[ "$DRY_RUN" = 1 ]]; then log would "rm $dst"; else log unlink "$dst"; rm "$dst"; fi
done

# Only for hosts without Homebrew; macOS gets these from the Brewfile.
if ! command -v brew >/dev/null 2>&1; then
  if ! command -v zoxide >/dev/null 2>&1; then
    run sh -c "$(curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh)"
  fi

  # The clone tracks upstream, and .zshrc warns once it is a month old.
  ZSH_PLUGINS="$HOME/.local/share/zsh"
  ensure_dir "$ZSH_PLUGINS"
  if [[ -L "$HOME/.zsh/zsh-autosuggestions" ]]; then
    run rm "$HOME/.zsh/zsh-autosuggestions"   # compat link from the move
  elif [[ -d "$HOME/.zsh/zsh-autosuggestions" && ! -d "$ZSH_PLUGINS/zsh-autosuggestions" ]]; then
    run mv "$HOME/.zsh/zsh-autosuggestions" "$ZSH_PLUGINS/zsh-autosuggestions"   # old location
  fi
  if [[ ! -d "$ZSH_PLUGINS/zsh-autosuggestions" ]]; then
    run git clone --quiet --depth 1 \
      https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGINS/zsh-autosuggestions"
  fi

  # zoxide replaced rupa/z. Its data in ~/.z stays.
  if [[ -d "$HOME/.zsh/z" ]]; then run rm -rf "$HOME/.zsh/z"; fi
  if [[ "$DRY_RUN" != 1 ]] && rmdir "$HOME/.zsh" 2>/dev/null; then log rmdir "$HOME/.zsh"; fi
fi
