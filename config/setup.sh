#!/usr/bin/env bash

set -o pipefail
set -e
set -x

### Simlink starship config
mkdir -p "$HOME/.config/"
ln -s "$(pwd)/starship.toml" "$HOME/.config/starship.toml"

### Simlink ghostty config
mkdir -p "$HOME/.config/ghostty/"
ln -s "$(pwd)/ghostty" "$HOME/.config/ghostty/config"
