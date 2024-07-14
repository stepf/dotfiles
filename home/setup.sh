#!/usr/bin/env bash

set -o pipefail
set -e
set -x

### Install zsh plugins
mkdir -p "$HOME/.zsh"
git clone --depth 1 "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$HOME/.zsh/zsh-syntax-highlighting"
git clone --depth 1 "https://github.com/zsh-users/zsh-autosuggestions.git" "$HOME/.zsh/zsh-autosuggestions"

### Simlink dotfiles to home directory
for file in *; do
  ln -s "$(pwd)/$file" "$HOME/.$file"
done
