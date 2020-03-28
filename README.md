# Dotfiles

Unless this repository has unexpectedly gone viral overnight, you probably asked me for my configuration during pair programming. Please cherrypick anything you need!

A little bit of context: I went from over-customization to a more light-weight approach. Wherever possible, all dotfiles use default settings and builtins instead of frameworks and plugins.

## Installation

Beware: No smart simlink management. I use these scripts to quickly bootstrap my dev machines running macOS or Ubuntu.

```bash
.
├── home/setup.sh          # Simlinks dotfiles to $HOME
├── macos/setup.sh         # Sets macOS defaults, installs CLIs and apps from Brewfile
├── starship/setup.sh      # Simlinks starship.toml to $HOME/.config/starship.toml
├── sublimetext/setup.sh   # Simlinks Sublime Text 3 settings
└── ubuntu/setup.sh        # Installs Linuxbrew
```

### Todo

- Sublime Text 3 Packages
- Alfred Workflows

## Contribute

- Show me in our next pair programming session :)
