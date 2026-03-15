#!/usr/bin/env bash

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "macOS Permissions Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Some tools require permissions to work correctly."
echo ""
echo "Please enable the following apps when the panels open:"
echo ""
echo "Accessibility"
echo "  ✓ Hammerspoon"
echo "  ✓ Alfred"
echo "  ✓ Ghostty"
echo ""
echo "Screen Recording"
echo "  ✓ Hammerspoon"
echo "  ✓ Alfred"
echo ""
echo "Full Disk Access (optional)"
echo "  ✓ Alfred"
echo ""
echo "Press ENTER to open the permission panels..."
read -r

########################################
# Accessibility
########################################

echo ""
echo "Opening Accessibility settings..."
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"

read -p "Press ENTER after enabling the apps above..."

########################################
# Screen Recording
########################################

echo ""
echo "Opening Screen Recording settings..."
open "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"

read -p "Press ENTER after enabling the apps above..."

########################################
# Full Disk Access
########################################

echo ""
echo "Opening Full Disk Access settings..."
open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"

read -p "Press ENTER when finished..."

echo ""
echo "Permissions setup complete."
echo ""
