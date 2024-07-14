# Dotfiles

Unless this repository has unexpectedly gone viral overnight, you probably asked me for my configuration during pair programming. Please cherrypick anything you need!

A little bit of context: I went from over-customization to a more light-weight approach. Wherever possible, all dotfiles use default settings and builtins instead of frameworks and plugins.

## Installation

Beware: No smart simlink management. I use these scripts to quickly bootstrap my dev setup running on macOS. Setup should be executed in the order below

```bash
.
├── macos/setup.sh         # Sets macOS defaults, installs CLIs and apps from Brewfile
├── home/setup.sh          # Simlinks dotfiles to $HOME
├── starship/setup.sh      # Simlinks starship.toml to $HOME/.config/starship.toml
└── sublimetext/setup.sh   # Simlinks Sublime Text 4 settings
```

### Todos

- Cursor / VSCode setup

## Contribute

- Show me in our next pair programming session :)
