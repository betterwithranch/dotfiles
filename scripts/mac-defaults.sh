#!/usr/bin/env zsh

# Show hidden files
defaults write com.apple.finder "AppleShowAllFiles" -bool "true"

# Default to list view in Finder
defaults write com.apple.finder "FXPreferredViewStyle" -string "Nlsv"

# Disable warning when changing file extensions
defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool "false"

killall Finder

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

killall Dock

# Auto-switch between light and dark mode
defaults write NSGlobalDomain "AppleInterfaceStyleSwitchesAutomatically" -bool "true"

# Silence system sounds
defaults write NSGlobalDomain "com.apple.sound.beep.volume" -float 0
defaults write NSGlobalDomain "com.apple.sound.uiaudio.enabled" -int 0
