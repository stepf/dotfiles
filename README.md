# Dotfiles

> Dotfiles are meant to be read, **not** meant to be forked.

Less is more:
- Defaults over configuration
- Builtins over plugins
- One `setup.sh` per directory over omnipotent management tools

## Usage

For every desired setup run `cd <subdirectory> && ./setup.sh`. The root `setup.sh` will run everything. Beware: No fancy logic. These scripts were intended for my dev machines running macOS.

### Subdirectories

```bash
.
├── home/setup.sh          # Simlinks the actual dotfiles to $HOME
├── macos/setup.sh         # Sets os defaults, installs CLIs and apps from Brewfile
└── sublimetext/setup.sh   # Simlinks Sublime Text 3 settings
```

### Todo

- Sublime Text 3 Packages
- Alfred Workflows
