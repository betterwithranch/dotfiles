#!/usr/bin/env zsh

echo
echo
echo "Xcode command line tools"
echo
echo

if ! xcode-select -p 1>/dev/null; then
  echo "Xcode command line tools are not installed. Installing ..."

  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')

  if ! softwareupdate -i "$PROD" --verbose; then
    echo "Error installing command line tools. Exiting ..."
    return 1 2>/dev/null || exit 1
  fi
fi

echo "Xcode command line tools are installed"
