#!/usr/bin/env zsh

echo "Setting up Finder sidebar favorites"

# Force-enable standard items to ensure the 'Favorites' section is visible
defaults write com.apple.sidebarlists favoritesitems -dict-add ShowDocuments -bool true
defaults write com.apple.sidebarlists favoritesitems -dict-add ShowDesktop -bool true

# Ensure the Sidebar itself is not hidden
defaults write com.apple.finder ShowSidebar -bool true

# Ensure directories exist
mkdir -p "$HOME/dev"

# Register favorites
/usr/bin/sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file://$HOME/obsidian"
/usr/bin/sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file://$HOME/dev"

killall Finder
