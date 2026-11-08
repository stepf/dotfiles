# Dotfiles

Light-weight dev setup, macOS first. Default settings and builtins over frameworks
and plugins. The shell, git and tmux config also run on Linux; everything under
`macos/` does not.

Layout: `home/` holds files linked as `~/.<name>` (a directory like `home/shims`
becomes `~/.shims`), `config/` mirrors `~/.config/`, and each tool with its own
setup logic has a directory (`claude/`, `vscode/`, `sublimetext/`). `macos/`
is the platform-only part.

## Personal and professional accounts on one machine

I use several accounts for the same tools on one machine. The directory I work
in picks the account: under `~/clients/<name>/`, git, `gh` and `claude` use
that name's identity and profile, everywhere else my personal ones. The
wrappers in `home/shims` switch `gh` and `claude`, an `includeIf` in
`config/git/config` switches git. The logic is thin, but enough for my
purposes.

## Installation

```bash
./setup.sh            # everything, in order; skips the macOS-only steps on Linux
./setup.sh --dry-run  # show what would change
```

Every script is idempotent and prints one line per step: `ok` when nothing
changed, `link`, `mkdir` or `run` when something did. `--dry-run` works on each
script alone too, for example `./claude/setup.sh --dry-run`.

The steps `setup.sh` runs, in this order:

1. `macos/setup.sh`: Xcode command line tools, Homebrew, Brewfiles, login shell, then macOS
   defaults, dock and display. Installs first, so a failed brew run leaves the
   desktop untouched.
2. `home/setup.sh`: symlink dotfiles to `$HOME`, install zoxide and clone
   zsh-autosuggestions on machines without Homebrew.
3. `config/setup.sh`: mirror `config/` into `~/.config` (git, starship,
   ghostty), create the machine-local git files, enable this repo's pre-commit
   hook.
4. `claude/setup.sh`: symlink Claude Code settings, statusline and output
   styles to `~/.claude`, and build a profile for each directory in
   `~/clients`.
5. `sublimetext/setup.sh`: symlink Sublime Text settings (skips if the app is
   not installed yet).
6. `vscode/setup.sh`: symlink VSCode settings, install extensions with brew bundle.

## Contribute

Show me in our next pair programming session :)
