#!/bin/bash

# Update package lists
sudo apt update -y
sudo apt upgrade -y

# Install Squid package
sudo apt install squid -y

# Create a backup of the original configuration file
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.original

# Edit Squid configuration (use nano or your preferred editor)
sudo nano /etc/squid/squid.conf

# Configure basic options (refer to Squid documentation for details)
# - http_port: Change the port if needed (default: 3128)
# - acl localnet src 10.0.0.0/8  # Allow access from your local network
# - http_access allow localnet  # Allow access only from local network
# - ... add other configurations as needed

# Restart Squid service
sudo systemctl restart squid

# Check Squid service status
sudo systemctl status squid

# Allow Squid through firewall (if using firewall)
# ufw allow http port  # Example for ufw firewall

# Optional: Add Squid user for authentication (refer to Squid documentation)
# sudo apt install apache2-utils -y  # Installs htpasswd tool
# sudo htpasswd -c /etc/squid/passwd username  # Create user with password

# If using authentication
# Edit squid.conf and add:
# - http_access deny all
# - http_access allow my_acl  # Replace with your ACL name
# Add ACL for authenticated users
# - acl my_acl proxy_auth user_list

echo "Squid proxy installed and configured!"
