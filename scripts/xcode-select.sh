#!/usr/bin/env zsh

echo
echo
echo "Xcode command line tools"
echo
echo

xcode-select -p 1>/dev/null

if [ $? -ne 0 ]; then
  echo "Xcode command line tools are not installed. Installing ..."
  sudo xcode-select --install

  echo "Select install from the dialog"

  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')

  softwareupdate -i "$PROD" --verbose

  if [ $? -ne 0 ]; then
    echo "Error installing command line tools. Exiting ..."
    exit 1
  fi
fi

echo "Xcode command line tools are installed"
