#!/usr/bin/env zsh

# Show hidden files
defaults write com.apple.finder "AppleShowAllFiles" -bool "false" && killall Finder
