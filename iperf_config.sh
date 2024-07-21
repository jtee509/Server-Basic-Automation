#!/bin/bash

# Check if iperf is already installed
if command -v iperf &> /dev/null; then
  echo "iperf is already installed."
  exit 0
fi

# Update package list
sudo apt update

# Install iperf
sudo apt install iperf

# Verify installation
if command -v iperf &> /dev/null; then
  echo "iperf installation successful."
else
  echo "iperf installation failed."
fi

