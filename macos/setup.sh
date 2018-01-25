#!/usr/bin/env bash

set -o pipefail
set -e
set -x

xcode-select --install                                                   # Install XCode Command Line Tools

# Finder
defaults write com.apple.finder CreateDesktop -bool false                # Hide Desktop Icons
defaults write com.apple.finder ShowPathbar -bool true                   # Show Pathbar
defaults write com.apple.finder ShowStatusBar -bool true                 # Show Statusbar
killall Finder

# Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install dependencies specified in Brewfile
brew tap Homebrew/bundle
brew bundle

# ZSH
sudo sh -c 'echo $(brew --prefix)/bin/zsh >> /etc/shells' \
  && chsh -s "$(brew --prefix)/bin/zsh"
