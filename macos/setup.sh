#!/usr/bin/env bash

set -o pipefail
set -e
set -x

# Install XCode Command Line Tools
xcode-select --install

# Dock settings
defaults write com.apple.dock "orientation" -string "left"
defaults write com.apple.dock "tilesize" -int "52"
defaults write com.apple.dock "autohide" -bool "true"
defaults write com.apple.dock "show-recents" -bool "false"
defaults write com.apple.dock "expose-group-apps" -bool "true" # Group apps in Mission Control
defaults write com.apple.dock "mru-spaces" -bool "false" # Don't rearrange spaces based on recent use

# Hot Corners: Disable all
defaults write com.apple.dock "wvous-tl-corner" -int 0
defaults write com.apple.dock "wvous-tr-corner" -int 0
defaults write com.apple.dock "wvous-bl-corner" -int 0
defaults write com.apple.dock "wvous-br-corner" -int 0

killall Dock

# Finder settings
defaults write com.apple.finder CreateDesktop -bool false # Hide Desktop Icons
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder "FXPreferredViewStyle" -string "Nlsv" # Use list view
defaults write com.apple.finder "FXArrangeGroupViewBy" -string "Name" # Arrange by name
defaults write com.apple.finder "ShowRecentTags" -bool false # Hide recent tags
defaults write com.apple.finder "SidebarWidth" -int 128
defaults write com.apple.finder "NewWindowTarget" -string "PfLo" # New window opens Downloads
defaults write com.apple.finder "NewWindowTargetPath" -string "file://${HOME}/Downloads/"
# List view settings
defaults write com.apple.finder StandardViewSettings -dict-add showIconPreview -bool true
defaults write com.apple.finder StandardViewSettings -dict-add calculateAllSizes -bool false
chflags nohidden ~/Library
killall Finder

# Keyboard settings: Globe key switches input sources
defaults write com.apple.HIToolbox AppleFnUsageType -int "1"

# Keyboard settings: Faster key repeat
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Keyboard settings: Disable auto-correct and auto-capitalize
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Trackpad settings: map bottom right corner to right-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true

# Trackpad settings: tracking speed
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 0.875

# Screenshot settings: Save to Downloads, disable shadow
defaults write com.apple.screencapture location -string "${HOME}/Downloads"
defaults write com.apple.screencapture disable-shadow -bool true

# Set language and text formats
defaults write NSGlobalDomain AppleLanguages -array "en-DE" "de-DE"
defaults write NSGlobalDomain AppleLocale -string "en_DE@currency=EUR"
killall cfprefsd

# Set default app handlers for file types
defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType=public.plain-text;LSHandlerRoleAll=com.sublimetext.4;}'
defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType=public.json;LSHandlerRoleAll=com.sublimetext.4;}'
defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType=net.daringfireball.markdown;LSHandlerRoleAll=com.sublimetext.4;}'
defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType=public.yaml;LSHandlerRoleAll=com.sublimetext.4;}'
defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType=public.shell-script;LSHandlerRoleAll=com.sublimetext.4;}'

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off

# Install dependencies specified in Brewfile
brew tap Homebrew/bundle
brew bundle

# Set up-to-date ZSH (installed via brew) as default shell
sudo sh -c 'echo $(brew --prefix)/bin/zsh >> /etc/shells' \
  && chsh -s "$(brew --prefix)/bin/zsh"
