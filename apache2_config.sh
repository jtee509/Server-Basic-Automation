#!/bin/bash

# Update package lists
echo "Updating system..."
sudo apt update

# Upgrade existing packages (optional, uncomment if desired)
echo "Upgrading system..."
sudo apt upgrade -y

# Install Apache2 and its dependencies
echo "Installing Apache2..."
sudo apt install apache2 apache2-utils -y

# Enable Apache2 service
echo "Enabling Apache2 service..."
sudo systemctl enable apache2

# Start Apache2 service
echo "Starting Apache2 service..."
sudo systemctl start apache2

if systemctl is-active --quiet "apache2"; then
  echo "apache2 is running"
else
  echo "apache2 is not running"
fi

echo "Apache2 installation complete!"
