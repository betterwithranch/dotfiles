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
echo "  ✓ Karabiner-Elements (karabiner_grabber)"
echo ""
echo "Input Monitoring"
echo "  ✓ Karabiner-Elements (karabiner_grabber, karabiner_observer)"
echo ""
echo "Screen Recording"
echo "  ✓ Hammerspoon"
echo "  ✓ Alfred"
echo ""
echo "Login Items & Extensions → Driver Extensions"
echo "  ✓ Karabiner-Elements (org.pqrs.Karabiner-DriverKit-VirtualHIDDevice)"
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
# Input Monitoring
########################################

echo ""
echo "Opening Input Monitoring settings..."
open "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"

read -p "Press ENTER after enabling the apps above..."

########################################
# Screen Recording
########################################

echo ""
echo "Opening Screen Recording settings..."
open "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"

read -p "Press ENTER after enabling the apps above..."

########################################
# Login Items & Extensions
########################################

echo ""
echo "Opening Login Items & Extensions settings..."
echo "Enable the Karabiner DriverKit VirtualHIDDevice driver extension."
open "x-apple.systempreferences:com.apple.LoginItems-Settings.extension"

read -p "Press ENTER after enabling the driver extension..."

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
