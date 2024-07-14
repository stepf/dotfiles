#!/usr/bin/env bash

set -o pipefail
set -e
set -x

### Simlink dotfiles to home directory
for file in *; do
  ln -s "$(pwd)/$file" "$HOME/.$file"
done
