# Dotfiles

Light-weight macOS dev setup. Default settings and builtins over frameworks and plugins.

## Installation

All scripts are idempotent — safe to re-run at any time, from any directory.

```bash
# 1. macOS defaults, Xcode CLT, Homebrew, Brewfile, display, shell
./macos/setup.sh

# 2. Symlink dotfiles to $HOME
./home/setup.sh

# 3. Symlink starship and ghostty to ~/.config
./config/setup.sh

# 4. Symlink Sublime Text settings (skips if app not installed yet)
./sublimetext/setup.sh

# 5. Symlink VSCode/Cursor settings + install extensions (skips if app not opened yet)
./vscode/setup.sh
```

## Structure

```
macos/
  setup.sh         # macOS defaults, Xcode CLT, Homebrew, Brewfile, display, dock, sidebar
  Brewfile         # CLIs, casks, MAS apps, fonts
  Raycast.rayconfig          # Raycast settings (imported automatically)
  com.local.KeyRemapping.plist  # Caps Lock → Escape (LaunchAgent)
home/
  setup.sh         # Symlinks all dotfiles to $HOME (as ~/.filename)
config/
  setup.sh         # Symlinks starship.toml and ghostty config
sublimetext/
  setup.sh         # Symlinks Sublime Text 4 preferences
vscode/
  setup.sh         # Symlinks settings.json to VSCode and Cursor
  Brewfile         # VSCode/Cursor extensions
```

## Contribute

Show me in our next pair programming session :)
