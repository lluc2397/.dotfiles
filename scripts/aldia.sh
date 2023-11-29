#!/bin/bash
apt update
apt -y upgrade
snap refresh
apt -y autoremove
apt autoclean
apt autopurge

# Get upgradable packages list
upgradable_packages=$(apt list --upgradable)

# Remove the first element
trimmed_packages="${upgradable_packages#*$'\n'}"

# Parse and remove everything after the first '/'
parsed_packages=$(echo "$trimmed_packages" | sed 's/\/.*//')

# Concatenate the parsed packages
concatenated_packages=$(echo "$parsed_packages" | tr '\n' ' ')

# Run apt upgrade with the concatenated packages
sudo apt upgrade $concatenated_packages
