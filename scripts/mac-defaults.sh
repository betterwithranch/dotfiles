#!/usr/bin/env zsh

# Show hidden files
defaults write com.apple.finder "AppleShowAllFiles" -bool "true" && killall Finder
