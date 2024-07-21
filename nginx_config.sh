#!/bin/bash

# Update package lists
sudo apt update

# Check if nginx is already installed
if [[ $(dpkg-query -l nginx | grep installed) ]]; then
  echo "nginx is already installed"
  exit 0
fi

# Install nginx and its dependencies
sudo apt install nginx -y

# Start nginx service
sudo systemctl start nginx

# Enable nginx to start automatically on boot
sudo systemctl enable nginx

# Show success message
echo "nginx installation complete!"

