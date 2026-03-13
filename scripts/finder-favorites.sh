#!/usr/bin/env zsh

echo "Setting up Finder sidebar favorites"

# Force-enable standard items to ensure the 'Favorites' section is visible
defaults write com.apple.sidebarlists favoritesitems -dict-add ShowDocuments -bool true
defaults write com.apple.sidebarlists favoritesitems -dict-add ShowDesktop -bool true

# Ensure the Sidebar itself is not hidden
defaults write com.apple.finder ShowSidebar -bool true

# Restart Finder to apply visibility changes
killall Finder

# Create sidebar anchor directory for symlinks
mkdir -p "$HOME/.sidebar_anchors"

# Create symlinks (work even if targets don't exist yet, e.g. before iCloud login)
ln -sfn "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents" "$HOME/.sidebar_anchors/Obsidian"
ln -sfn "$HOME/dev" "$HOME/.sidebar_anchors/dev"

# Register anchors with Finder favorites
/usr/bin/sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file://$HOME/.sidebar_anchors/Obsidian"
/usr/bin/sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file://$HOME/.sidebar_anchors/dev"

# Restart Finder to pick up new favorites
killall Finder
