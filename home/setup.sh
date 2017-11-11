#!/usr/bin/env bash

set -o pipefail
set -e
set -x

### Install zsh theme
mkdir -p "$HOME/.zsh/.zfunctions"
git clone "https://github.com/sindresorhus/pure.git" "$HOME/.zsh/pure"
ln -s "$HOME/.zsh/pure/pure.zsh"  "$HOME/.zsh/.zfunctions/prompt_pure_setup"
ln -s "$HOME/.zsh/pure/async.zsh" "$HOME/.zsh/.zfunctions/async"

### Install zsh plugins
mkdir -p "$HOME/.zsh"
git clone "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$HOME/.zsh/zsh-syntax-highlighting"
git clone "https://github.com/zsh-users/zsh-autosuggestions.git"     "$HOME/.zsh/zsh-autosuggestions"

### Simlink dotfiles to home directory
for file in *; do
  ln -s "$(pwd)/$file" "$HOME/.$file"
done
