#!/usr/bin/env zsh

# Configure macOS menu bar items

echo "Configuring menu bar..."

# Control Center items - visible
defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible NowPlaying" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible Clock" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible BentoBox" -bool true

# Control Center items - hidden
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible FocusModes" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible ScreenMirroring" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible AudioVideoModule" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible FaceTime" -bool false

# Clock: show day of week and AM/PM, hide date
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write com.apple.menuextra.clock ShowAMPM -bool true
defaults write com.apple.menuextra.clock ShowDate -int 0

# Hide Siri from menu bar
defaults write com.apple.Siri StatusMenuVisible -bool false

# Restart affected processes
killall ControlCenter 2>/dev/null
killall SystemUIServer 2>/dev/null

echo "Menu bar configured."
