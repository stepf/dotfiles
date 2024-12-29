# Dotfiles

Unless this repository has unexpectedly gone viral overnight, you probably asked me for bits of my configuration during pair programming. Please cherrypick anything you need!

A little bit of context: I went from over-customization to a more light-weight approach. Wherever possible, all dotfiles use default settings and builtins instead of frameworks and plugins.

## Installation

Beware: No smart simlink management. I use these scripts to quickly bootstrap my dev setup running on macOS. Setup should be executed in the order below

```bash
.
├── macos/setup.sh         # Sets macOS defaults, installs CLIs and apps from Brewfile
├── home/setup.sh          # Simlinks dotfiles to $HOME
├── config/setup.sh        # Simlinks starship to $HOME/.config
├── sublimetext/setup.sh   # Simlinks Sublime Text 4 settings
└── vscode/setup.sh        # Simlinks VSCode & Cursor settings
```

## Contribute

- Show me in our next pair programming session :)
