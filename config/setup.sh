#!/usr/bin/env bash

set -o pipefail
set -e
set -x

mkdir -p "$HOME/.config/"

### Simlink starship config
ln -s "$(pwd)/starship.toml" "$HOME/.config/starship.toml"
