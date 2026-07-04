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

### Manual steps after running scripts

- **MD IO Trial font** — download from https://mass-driver.com/trial-fonts, copy to `~/Library/Fonts/`
- **Arc** — log in, configure profiles, extensions, and unsynced favorites
- **OpenVPN** — import `.ovpn` profile
- **1Password** — log in

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

## Remote hosts (terminfo)

Ghostty sets `TERM=xterm-ghostty`, which most servers don't know. Symptoms on
SSH: broken line editing, `tput: unknown terminal`, `clear`/`less`/`vim` errors.
Fix by installing the entry into the remote `~/.terminfo` (done for Uberspace
2026-07-01, same pattern as `tmux-256color` earlier):

```bash
infocmp -x xterm-ghostty | ssh <host> -- tic -x -
```

Re-run after Ghostty terminfo updates or on any new host.

## Contribute

Show me in our next pair programming session :)
