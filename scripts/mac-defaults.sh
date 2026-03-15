#!/usr/bin/env zsh

# Show hidden files
defaults write com.apple.finder "AppleShowAllFiles" -bool "true"

# Default to list view in Finder
defaults write com.apple.finder "FXPreferredViewStyle" -string "Nlsv"

# Disable warning when changing file extensions
defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool "false"

# Prevents lag when switching workspaces.
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show all file extensions
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"

# Don't create .DS_Store on network or USB volumes
defaults write com.apple.desktopservices "DSDontWriteNetworkStores" -bool "true"
defaults write com.apple.desktopservices "DSDontWriteUSBStores" -bool "true"

# Disable smart quotes and dashes
defaults write NSGlobalDomain "NSAutomaticQuoteSubstitutionEnabled" -bool "false"
defaults write NSGlobalDomain "NSAutomaticDashSubstitutionEnabled" -bool "false"

# Expand save dialog by default
defaults write NSGlobalDomain "NSNavPanelExpandedStateForSaveMode" -bool "true"

# Only show running apps in the Dock
defaults write com.apple.dock "static-only" -bool "true"

# Auto-hide the Dock
defaults write com.apple.dock "autohide" -bool "true"

# Don't rearrange Spaces based on most recent use
defaults write com.apple.dock "mru-spaces" -bool "false"

# Hot corner: bottom-right → Lock Screen
defaults write com.apple.dock "wvous-br-corner" -int 13
defaults write com.apple.dock "wvous-br-modifier" -int 0

# Do not group windows in Mission Control
defaults write com.apple.dock expose-group-by-app -bool false

# Speeds up workspace switching
defaults write com.apple.dock expose-animation-duration -float 0.1

# Disable recent in dock
defaults write com.apple.dock show-recents -bool false

# Don't span displays with spaces
defaults write com.apple.spaces spans-displays -bool false

# Auto-switch between light and dark mode
defaults write NSGlobalDomain "AppleInterfaceStyleSwitchesAutomatically" -bool "true"

# Silence system sounds
defaults write NSGlobalDomain "com.apple.sound.beep.volume" -float 0
defaults write NSGlobalDomain "com.apple.sound.uiaudio.enabled" -int 0

# Screenshot improvements
mkdir -p ~/Screenshots

defaults write com.apple.screencapture location -string "$HOME/Screenshots"
defaults write com.apple.screencapture type -string "png"

# Don't restore windows on reboot
defaults write com.apple.Terminal NSQuitAlwaysKeepsWindows -bool false

# Keyboard improvements
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Trackpad improvements
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Desktop switching shortcuts
# add 79 and 80 to disable arrow switching
for id in 118 119 120 121; do
  /usr/libexec/PlistBuddy \
    -c "Set :AppleSymbolicHotKeys:$id:enabled false" \
    ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null
done

killall Dock
killall Finder
killall SystemUIServer
