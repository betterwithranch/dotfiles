#!/usr/bin/env zsh

# Detect current macOS menu bar configuration
# Run this on a machine you've manually configured to capture settings

echo "=== Menu Bar Status Items ==="
echo
echo "Visible items:"
defaults read com.apple.controlcenter 2>/dev/null | grep "NSStatusItem Visible" | grep "= 1" | sed 's/.*Visible /  /' | sed 's/".*//'
echo
echo "Hidden items:"
defaults read com.apple.controlcenter 2>/dev/null | grep "NSStatusItem Visible" | grep "= 0" | sed 's/.*Visible /  /' | sed 's/".*//'

echo
echo "=== Clock Settings ==="
echo "  ShowDate:      $(defaults read com.apple.menuextra.clock ShowDate 2>/dev/null || echo 'not set')"
echo "  ShowDayOfWeek: $(defaults read com.apple.menuextra.clock ShowDayOfWeek 2>/dev/null || echo 'not set')"
echo "  ShowAMPM:      $(defaults read com.apple.menuextra.clock ShowAMPM 2>/dev/null || echo 'not set')"
echo "  ShowSeconds:   $(defaults read com.apple.menuextra.clock ShowSeconds 2>/dev/null || echo 'not set')"
echo "  IsAnalog:      $(defaults read com.apple.menuextra.clock IsAnalog 2>/dev/null || echo 'not set')"

echo
echo "=== Battery ==="
echo "  ShowPercentage: $(defaults -currentHost read com.apple.controlcenter BatteryShowPercentage 2>/dev/null || echo 'not set')"

echo
echo "=== Spotlight ==="
echo "  MenuItemHidden: $(defaults -currentHost read com.apple.Spotlight MenuItemHidden 2>/dev/null || echo 'not set')"

echo
echo "=== Siri ==="
echo "  StatusMenuVisible: $(defaults read com.apple.Siri StatusMenuVisible 2>/dev/null || echo 'not set')"

echo
echo "=== Item Positions (left to right, higher = further left) ==="
defaults read com.apple.controlcenter 2>/dev/null | grep "Preferred Position" | sort -t= -k2 -rn | sed 's/.*Position /  /' | sed 's/[";]//g'
