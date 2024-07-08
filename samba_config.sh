#!/bin/bash

# Update package lists (adjust for your package manager if needed)
sudo apt update

# Install Samba and additional tools (adjust as required)
sudo apt install samba samba-common-tools

# Define the share directory path (replace with your desired path)
share_dir="/path/to/your/share"  # Make sure to replace this with your actual path

# Create the share directory (check if it exists first, optional)
if [ ! -d "$share_dir" ]; then
  sudo mkdir -p "$share_dir"
fi

# Set ownership and permissions for the share directory (adjust as needed)
sudo chown root:smbgrp "$share_dir"
sudo chmod 750 "$share_dir"

# Create a basic Samba configuration file (/etc/samba/smb.conf)
sudo touch /etc/samba/smb.conf

# Minimum recommended configuration for a secure share (adjust as needed)
sudo cat << EOF >> /etc/samba/smb.conf
[global]
   workgroup = WORKGROUP  # Replace with your desired workgroup name
   server signing = auto
   client signing = auto
   #  Uncomment and set a strong password for security
   #  security = share
   #  map to guest = bad user

[ShareName]  # Replace with your desired share name
   path = $share_dir  # Use the variable here
   browseable = yes
   read only = no
   create mask = 0660
   directory mask = 0750
   public = no
   # Uncomment for encrypted communication (recommended)
   #  encrypt passwords = yes

# Add additional share definitions and options here
EOF

# Restart Samba services to apply the configuration
sudo systemctl restart smb nmb

# Check Samba status (optional)
sudo systemctl status smb nmb

echo "Samba installation and basic configuration complete."