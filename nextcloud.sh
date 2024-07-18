#!/bin/bash

# Replace placeholders with actual values
OS="ubuntu"
WEB_SERVER="apache2"
DATABASE="mysql"
PHP_VERSION="8.1"

# Update package lists
apt update -y

# Install dependencies
apt install -y $WEB_SERVER $DATABASE-server php$PHP_VERSION libapache2-mod-php$PHP_VERSION php$PHP_VERSION-mysql php$PHP_VERSION-gd php$PHP_VERSION-curl php$PHP_VERSION-zip php$PHP_VERSION-intl

# Create database and user
mysql -u root -p << EOF
CREATE DATABASE nextcloud;
CREATE USER 'nextclouduser'@'localhost' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextclouduser'@'localhost';
FLUSH PRIVILEGES;
EOF

# Download and extract Nextcloud
wget https://download.nextcloud.com/server/latest/nextcloud.zip
unzip nextcloud.zip -d /var/www/html/
chown -R www-data:www-data /var/www/html/nextcloud

# Configure web server (example for Apache)
a2enmod rewrite
a2ensite default-ssl
sed -i 's/DocumentRoot \/\var\/www\/html/DocumentRoot \/\var\/www\/html\/nextcloud/' /etc/apache2/sites-available/default-ssl
service apache2 restart

# Open ports (adjust firewall rules as needed)
ufw allow 80/tcp
ufw allow 443/tcp

