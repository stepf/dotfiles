#!/usr/bin/env bash

set -o pipefail
set -e
set -x

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Install XCode Command Line Tools
if ! xcode-select -p &>/dev/null; then
  xcode-select --install
  echo "Waiting for Xcode CLT installation to complete..."
  until xcode-select -p &>/dev/null; do sleep 5; done
fi

# Dock settings
defaults write com.apple.dock "persistent-apps" -array # Remove all stock apps from dock
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

killall Dock || true

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
killall Finder || true

# Hide menubar items (24 = hidden, 18 = visible)
# Kept visible: WiFi, Battery, Clock, Control Center (not hideable via defaults)
MENUBAR_PLIST=~/Library/Preferences/ByHost/com.apple.controlcenter.plist
defaults write "$MENUBAR_PLIST" Bluetooth -int 24
defaults write "$MENUBAR_PLIST" Display -int 24
defaults write "$MENUBAR_PLIST" Sound -int 24
defaults write "$MENUBAR_PLIST" NowPlaying -int 24
defaults write "$MENUBAR_PLIST" FocusModes -int 24
defaults write "$MENUBAR_PLIST" KeyboardBrightness -int 24
defaults write "$MENUBAR_PLIST" AirDrop -int 24
defaults -currentHost write com.apple.Spotlight MenuItemHidden -bool true
killall SystemUIServer || true

# Disable notifications (best-effort, fragile across macOS versions)
defaults write com.apple.ncprefs content_visibility -dict-add "com.apple.ncprefs.content_visibility.global" -int 0
defaults write com.apple.controlcenter "NSStatusItem Visible DoNotDisturb" -bool true

# Keyboard settings: Globe key switches input sources
defaults write com.apple.HIToolbox AppleFnUsageType -int "1"

# Keyboard settings: Faster key repeat
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Keyboard settings: Disable auto-correct and auto-capitalize
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Keyboard settings: Map Caps Lock to Escape (immediate + persistent via LaunchAgent)
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}'
mkdir -p ~/Library/LaunchAgents
cp "${SCRIPT_DIR}/com.local.KeyRemapping.plist" ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.local.KeyRemapping.plist 2>/dev/null || true

# Trackpad settings: map bottom right corner to right-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true

# Trackpad settings: tracking speed (slider range 0–3)
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 0.875

# Trackpad settings: disable dictionary lookup (three-finger tap)
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 0

# Screenshot settings: Save to Downloads, disable shadow
defaults write com.apple.screencapture location -string "${HOME}/Downloads"
defaults write com.apple.screencapture disable-shadow -bool true

# Set language and text formats
defaults write NSGlobalDomain AppleLanguages -array "en-DE" "de-DE"
defaults write NSGlobalDomain AppleLocale -string "en_DE@currency=EUR"
killall cfprefsd || true

# Set default app handlers for file types (duti is idempotent, unlike -array-add)
if command -v duti &>/dev/null; then
  duti -s com.sublimetext.4 public.plain-text all
  duti -s com.sublimetext.4 public.json all
  duti -s com.sublimetext.4 net.daringfireball.markdown all
  duti -s com.sublimetext.4 public.yaml all
  duti -s com.sublimetext.4 public.shell-script all
fi

# Install Homebrew
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
brew analytics off

# Install dependencies specified in Brewfile
brew bundle --file="${SCRIPT_DIR}/Brewfile" --no-upgrade

# Install MAS apps (personal Mac only — company Mac uses Jamf self-service)
if ! command -v jamf &>/dev/null; then
  brew bundle --file="${SCRIPT_DIR}/Brewfile.mas" --no-upgrade
fi

# Set up-to-date ZSH (installed via brew) as default shell
BREW_ZSH="$(brew --prefix)/bin/zsh"
if ! grep -qF "$BREW_ZSH" /etc/shells; then
  sudo sh -c "echo $BREW_ZSH >> /etc/shells"
fi
if [ "$SHELL" != "$BREW_ZSH" ]; then
  chsh -s "$BREW_ZSH"
fi

# --- Post-brew setup (requires tools from Brewfile) ---

# Finder sidebar favorites
mkdir -p ~/work ~/scratch
mysides list | awk -F' -> ' '{print $1}' | while read -r name; do
  mysides remove "$name" 2>/dev/null || true
done
mysides add Applications "file://${HOME}/Applications"
mysides add Desktop "file://${HOME}/Desktop"
mysides add Downloads "file://${HOME}/Downloads"
mysides add work "file://${HOME}/work"
mysides add scratch "file://${HOME}/scratch"
mysides add Documents "file://${HOME}/Documents"

# Add apps to dock (searches both /Applications and ~/Applications)
DOCK_APP_NAMES=(
  "Arc"
  "Ghostty"
  "Slack"
  "Visual Studio Code"
  "Cursor"
)
for name in "${DOCK_APP_NAMES[@]}"; do
  app=""
  if [ -e "/Applications/${name}.app" ]; then
    app="/Applications/${name}.app"
  elif [ -e "${HOME}/Applications/${name}.app" ]; then
    app="${HOME}/Applications/${name}.app"
  fi
  if [ -n "$app" ]; then
    defaults write com.apple.dock persistent-apps -array-add \
      "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>${app}</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
  fi
done
killall Dock || true

# Import Raycast config (kept in personal-assets/, not committed)
RAYCAST_CONFIG="${SCRIPT_DIR}/../personal-assets/Raycast.rayconfig"
if [ -f "$RAYCAST_CONFIG" ]; then
  open "$RAYCAST_CONFIG"
fi

# Set built-in display to "More Space" resolution (idempotent)
# Get available modes with: displayplacer list
TARGET_RES="res:1800x1169 scaling:on"
if ! displayplacer list 2>/dev/null | grep -q "current mode.*${TARGET_RES}"; then
  displayplacer "id:1 ${TARGET_RES}"
fi

# Install MD IO Trial font (no direct download URL available)
# Download manually from: https://mass-driver.com/trial-fonts
# Then copy to ~/Library/Fonts/
