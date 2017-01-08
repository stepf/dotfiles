#!/usr/bin/env bash

xcode-select --install                                                   # Install XCode Command Line Tools

# Finder
defaults write com.apple.finder CreateDesktop -bool false                # Hide Desktop Icons
defaults write com.apple.finder ShowPathbar -bool true                   # Show Pathbar
defaults write com.apple.finder ShowStatusBar -bool true                 # Show Statusbar
killall Finder

# ZSH
brew install zsh && \
sudo sh -c 'echo $(brew --prefix)/bin/zsh >> /etc/shells' && \
chsh -s $(brew --prefix)/bin/zsh
