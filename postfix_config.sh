#!/bin/bash

# Update package lists
sudo apt update

# Install Postfix
sudo apt install postfix

# Configure Postfix during installation (select Internet Site)
#   - Enter your system's hostname when prompted

# (Optional) Install mail utilities for testing
sudo apt install mailutils
