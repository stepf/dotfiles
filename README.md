# Dotfiles

This is my personal dev setup. I use multiple machines, both macOS and Linux, so I try to keep my config as portable as possible and prefer default settings and built-in features (over frameworks and plugins). My setup aims to help me stay effective and provide lots of nice-to-haves, but for the must-haves I want retain the muscle memory to navigate almost any setup.

I work in several environments and on personal projects so my setup lets me use use several accounts for the same tools.

## Install

```bash
./setup.sh                # run steps 1 to 6 below; on Linux only steps 2 to 4
./setup.sh --dry-run      # show what would change, change nothing
./home/setup.sh --dry-run # the same for a single step
```

Each setup script should be idempotent and prints:

- `ok`: nothing changed
- `link`, `mkdir`, `run`, `unlink`: something did
- `would`: what `--dry-run` would do
- `skip`: an app is not installed yet
- `warn`: a real file was in the way and was moved to `.bak`

The global setup script runs these steps in this specific order:

1. `macos/setup.sh`: Xcode command line tools, Homebrew, Brewfiles, login shell,
   then macOS defaults, dock and display. It installs first, so a failed brew
   run leaves the desktop untouched.
2. `home/setup.sh`: symlink dotfiles to `$HOME`, install zoxide and clone
   zsh-autosuggestions on machines without Homebrew.
3. `config/setup.sh`: mirror `config/` into `~/.config` (git, starship,
   ghostty). Create `~/.config/git/local.gitconfig` (your identity and URL
   rewrites) and `~/.config/git/scrub.sed` (sections to strip before commit).
   Enable this repo's pre-commit hook.
4. `claude/setup.sh`: symlink Claude Code settings, statusline and output styles
   to `~/.claude`. Build a profile in `~/.claude-profiles/<name>` for each
   `~/clients/<name>`, and mirror a `<name>-2` profile.
5. `sublimetext/setup.sh`: symlink Sublime Text settings (skips if the app is
   not installed yet).
6. `vscode/setup.sh`: symlink VSCode settings (skips if the app is not
   installed yet), then install extensions with brew bundle.

### Pre-Installation

1. macOS: run `xcode-select --install`.
2. Linux: Ensure `git`, `curl` and `zsh` (as login shell) are available.
3. Clone to a path that does not move, otherwise it breaks all symlinks.
4. Optional, macOS: Copy the newest Raycast export into `private/` (gitignored). Make sure all fonts are installed.

## Contribute

Show me in our next pair programming session :)
