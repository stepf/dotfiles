#!/usr/bin/env bash
# Installs run before the defaults, which need tools and apps from the Brewfile.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/../lib.sh"

### Phase 1: install

# Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
  run xcode-select --install
  if [ "$DRY_RUN" != 1 ]; then
    echo "Waiting for Xcode CLT installation to complete..."
    until xcode-select -p &>/dev/null; do sleep 5; done
  fi
fi

# Homebrew
if ! command -v brew &>/dev/null; then
  run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
run brew analytics off

# Homebrew doesn't create the Brewfile's appdir, and casks fail without it.
ensure_dir "$HOME/Applications"

run brew bundle --file="${SCRIPT_DIR}/Brewfile" --no-upgrade

# App Store apps only on the personal Mac. The company Mac has jamf and uses Self Service.
if ! command -v jamf &>/dev/null; then
  run brew bundle --file="${SCRIPT_DIR}/Brewfile.mas" --no-upgrade
fi

# Make brew's zsh the login shell. The -x guard matters, because chsh to a missing shell locks out new terminals.
BREW_ZSH="$(brew --prefix 2>/dev/null || echo /opt/homebrew)/bin/zsh"
if [ -x "$BREW_ZSH" ]; then
  if ! grep -qF "$BREW_ZSH" /etc/shells; then
    run sudo sh -c "echo $BREW_ZSH >> /etc/shells"
  fi
  # Not $SHELL, which only changes at the next login.
  LOGIN_SHELL="$(dscl . -read "/Users/$(whoami)" UserShell 2>/dev/null | awk '{print $2}')"
  if [ "$LOGIN_SHELL" != "$BREW_ZSH" ]; then
    run chsh -s "$BREW_ZSH"
  fi
fi

ensure_dir ~/work
ensure_dir ~/scratch

# The MD IO Trial font is a manual step: download it from https://mass-driver.com/trial-fonts into ~/Library/Fonts.

### Phase 2: system defaults (run bare, so --dry-run skips the whole phase)
if [ "$DRY_RUN" = 1 ]; then
  log would "apply macOS defaults, dock, keyboard, trackpad and display (phase 2)"
  exit 0
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

# Add apps to dock (searches both /Applications and ~/Applications)
DOCK_APP_NAMES=(
  "Arc"
  "Ghostty"
  "Slack"
  "Visual Studio Code"
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
  else
    log skip "dock: ${name}.app not installed"
  fi
done
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

# Show Focus in the menu bar. The other menu bar items have no defaults keys since macOS 26.
defaults write com.apple.controlcenter "NSStatusItem Visible FocusModes" -bool true

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
ensure_dir ~/Library/LaunchAgents
cp "${SCRIPT_DIR}/com.local.KeyRemapping.plist" ~/Library/LaunchAgents/
# This fails harmlessly when the agent is already loaded.
launchctl bootstrap "gui/$(id -u)" ~/Library/LaunchAgents/com.local.KeyRemapping.plist 2>/dev/null || true

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

# Default app per file type
if command -v duti &>/dev/null; then
  duti -s com.sublimetext.4 public.plain-text all
  duti -s com.sublimetext.4 public.json all
  duti -s com.sublimetext.4 net.daringfireball.markdown all
  duti -s com.sublimetext.4 public.yaml all
  duti -s com.sublimetext.4 public.shell-script all
else
  log skip "duti not installed, default app handlers unchanged"
fi

# Import the newest Raycast export from private/, iCloud Drive/Raycast or Downloads.
# Raycast then asks for the export's passphrase.
RAYCAST_ICLOUD="${HOME}/Library/Mobile Documents/com~apple~CloudDocs/Raycast"
[ -d "$RAYCAST_ICLOUD" ] && { brctl download "$RAYCAST_ICLOUD" 2>/dev/null || true; }
RAYCAST_CONFIG=""
for f in "${SCRIPT_DIR}"/../private/*.rayconfig "$RAYCAST_ICLOUD"/*.rayconfig "$HOME"/Downloads/*.rayconfig; do
  [ -f "$f" ] || continue
  if [ -z "$RAYCAST_CONFIG" ] || [ "$f" -nt "$RAYCAST_CONFIG" ]; then RAYCAST_CONFIG="$f"; fi
done
if [ -n "$RAYCAST_CONFIG" ]; then
  log run "import $RAYCAST_CONFIG"
  open -a Raycast "$RAYCAST_CONFIG"
else
  warn "No Raycast export found, so Raycast settings were NOT imported."
  warn "On the old Mac: Raycast > Export Settings & Data, save to iCloud Drive/Raycast, then rerun."
fi

# Set the built-in display to "More Space". `displayplacer list` shows modes and ids.
TARGET_RES="res:1800x1169 scaling:on"
if command -v displayplacer &>/dev/null; then
  SCREEN_ID="$(displayplacer list 2>/dev/null | awk '/Persistent screen id/ {print $NF; exit}')"
  if [ -n "$SCREEN_ID" ] && ! displayplacer list 2>/dev/null | grep -q "current mode.*${TARGET_RES}"; then
    displayplacer "id:${SCREEN_ID} ${TARGET_RES}"
  fi
else
  log skip "displayplacer not installed, display resolution unchanged"
fi
