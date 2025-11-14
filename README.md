# Dotfiles

Unless this repository has unexpectedly gone viral overnight, you probably asked me for bits of my configuration during pair programming. Please cherrypick anything you need!

A little bit of context: I went from over-customization to a more light-weight approach. Wherever possible, all dotfiles use default settings and builtins instead of frameworks and plugins.

## Installation

Beware: No smart symlink management. I use these scripts to quickly bootstrap my dev setup running on macOS. Setup should be executed in the order below

```bash
.
├── macos/setup.sh         # Sets macOS defaults, installs CLIs and apps from Brewfile
├── home/setup.sh          # Symlinks dotfiles to $HOME
├── config/setup.sh        # Symlinks starship and ghostty to $HOME/.config
├── sublimetext/setup.sh   # Symlinks Sublime Text 4 settings
└── vscode/setup.sh        # Symlinks VSCode/Cursor settings (shared config)
```

## Contribute

- Show me in our next pair programming session :)
