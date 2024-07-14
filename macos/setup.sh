#!/usr/bin/env bash

set -o pipefail
set -e
set -x

# Install XCode Command Line Tools
xcode-select --install

# Set Finder settings
defaults write com.apple.finder CreateDesktop -bool false # Hide Desktop Icons
defaults write com.apple.finder ShowPathbar -bool true    # Show Pathbar
defaults write com.apple.finder ShowStatusBar -bool true  # Show Statusbar
killall Finder

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off

# Install dependencies specified in Brewfile
brew tap Homebrew/bundle
brew bundle

# Set up-to-date ZSH (installed via brew) as default shell
sudo sh -c 'echo $(brew --prefix)/bin/zsh >> /etc/shells' \
  && chsh -s "$(brew --prefix)/bin/zsh"
