#!/usr/bin/env bash

set -o pipefail
set -e
set -x

### Install zsh theme
mkdir -p "$HOME/.config/"
ln -s "$(pwd)/starship.toml" "$HOME/.config/starship.toml"
