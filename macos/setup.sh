#!/usr/bin/env bash

set -o pipefail
set -e
set -x

# Install XCode Command Line Tools
xcode-select --install

# Dock settings
defaults write com.apple.dock "orientation" -string "left"
defaults write com.apple.dock "tilesize" -int "48"
defaults write com.apple.dock "autohide" -bool "true"
defaults write com.apple.dock "show-recents" -bool "false"
defaults write com.apple.dock "expose-group-apps" -bool "true" # Group apps in Mission Control
killall Dock

# Finder settings
defaults write com.apple.finder CreateDesktop -bool false # Hide Desktop Icons
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder "FXPreferredViewStyle" -string "Nlsv" # Use list view
chflags nohidden ~/Library
killall Finder

# Keyboard settings: Globe key switches input sources
defaults write com.apple.HIToolbox AppleFnUsageType -int "1"

# Trackpad settings: map bottom right corner to right-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true

# Set language and text formats
defaults write NSGlobalDomain AppleLanguages -array "en-DE" "de-DE"
defaults write NSGlobalDomain AppleLocale -string "en_DE@currency=EUR"
killall cfprefsd

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off

# Install dependencies specified in Brewfile
brew tap Homebrew/bundle
brew bundle

# Set up-to-date ZSH (installed via brew) as default shell
sudo sh -c 'echo $(brew --prefix)/bin/zsh >> /etc/shells' \
  && chsh -s "$(brew --prefix)/bin/zsh"
