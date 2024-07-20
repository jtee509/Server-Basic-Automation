#!/bin/bash

# Simplify directory structure (assuming script and files are in the same location)
website_dir=$(pwd)

# Create example HTML files (replace with your content)
echo "<h1>Welcome to Example Website 1</h1>" > example1.html
echo "<h1>Welcome to Example Website 2</h1>" > example2.html

# Configure nginx server blocks
sudo cat << EOF > /etc/nginx/conf.d/multisite.conf
server {
  listen 8001;
  server_name localhost;

  # Access restriction for localhost only
  allow 127.0.0.1;
  deny all;

  root $website_dir;
  index example1.html;
  location / {
    try_files $uri $uri/ =404;
  }
}

server {
  listen 8002;
  server_name localhost;

  # Access restriction for localhost only
  allow 127.0.0.1;
  deny all;

  root $website_dir;
  index example2.html;
  location / {
    try_files $uri $uri/ =404;
  }
}
EOF

# Reload nginx configuration
sudo systemctl reload nginx

echo "Websites are now running on ports 8001 and 8002 (localhost only)"
