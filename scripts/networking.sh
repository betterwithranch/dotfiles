#! /usr/bin/env zsh

services=$(networksetup -listallnetworkservices | grep 'Wi-Fi\|Ethernet\|USB')
while read -r service; do
  echo "Setting DNS for $service"
  networksetup -setdnsservers "$service" 1.1.1.1 1.0.0.1 2606:4700:4700::1111 2606:4700:4700::1001
done <<<"$services"
