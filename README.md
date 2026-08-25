# Dotfiles

Light-weight dev setup, macOS first. Default settings and builtins over frameworks
and plugins. The shell, git and tmux config also run on Linux; everything under
`macos/` does not.

## Installation

All scripts are idempotent — safe to re-run at any time, from any directory.

```bash
# 1. macOS defaults, Xcode CLT, Homebrew, Brewfiles, dock, display, login shell
./macos/setup.sh

# 2. Symlink dotfiles to $HOME, create the machine-local git files,
#    clone zsh plugins on machines without Homebrew
./home/setup.sh

# 3. Symlink starship and ghostty configs to ~/.config
./config/setup.sh

# 4. Symlink Claude Code settings, statusline and output styles to ~/.claude,
#    and build a profile in ~/.claude-profiles for each dir in ~/clients
./claude/setup.sh

# 5. Symlink Sublime Text settings (skips if the app is not installed yet)
./sublimetext/setup.sh

# 6. Symlink VSCode settings, then install extensions with brew bundle
./vscode/setup.sh
```

On Linux, run steps 2 to 4. Step 1 is macOS-only, and steps 5 and 6 need macOS
paths and Homebrew.

## Contribute

Show me in our next pair programming session :)
