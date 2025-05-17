#!/usr/bin/env bash

echo
echo
echo "Xcode command line tools"
echo
echo

xcode-select -p 1>/dev/null

if [ $? -ne 0 ]; then
  echo "Xcode command line tools are not installed. Installing ..."
  sudo xcode-select --install

  if [ $? -ne 0 ]; then
    echo "Error installing command line tools. Exiting ..."
    exit 1
  fi
fi

echo "Xcode command line tools are installed"
