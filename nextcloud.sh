#!/bin/bash

# Install dependencies
sudo apt update
sudo apt install -y apache2 php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-zip

# Install Nextcloud
sudo snap install nextcloud

# Configure Apache
sudo tee /etc/apache2/conf.d/nextcloud.conf <<EOF
Alias /nextcloud "/var/snap/nextcloud/current/nextcloud"

<Directory /var/snap/nextcloud/current/nextcloud>
  Options +FollowSymlinks
  AllowOverride All

  <IfModule mod_dav.c>
    Dav off
  </IfModule>

  SetEnv HOME /var/snap/nextcloud/current/nextcloud
  SetEnv HTTP_HOME /var/snap/nextcloud/current/nextcloud

  Satisfy Any

</Directory>
EOF

sudo a2enmod rewrite
sudo a2enmod headers
sudo service apache2 restart

# Configure Nextcloud
sudo nextcloud.occ config:system:set trusted_domains 1 --value=localhost
sudo nextcloud.occ config:system:set trusted_domains 2 --value=yourdomain.com
sudo nextcloud.occ config:system:set overwrite.cli.url /nextcloud
sudo nextcloud.occ config:system:set overwrite.web.root /nextcloud

# Create Nextcloud admin user
sudo nextcloud.occ user:add --display-name "Admin" --user-name "admin" --password "your_admin_password"

# Enable SSL (optional)
#sudo nextcloud.occ config:system:set overwrite.cli.url https://localhost/nextcloud
#sudo nextcloud.occ config:system:set overwrite.web.root https://localhost/nextcloud

# Restart Nextcloud
sudo snap restart nextcloud

echo "Nextcloud installed and configured. You can access it at http://localhost/nextcloud"