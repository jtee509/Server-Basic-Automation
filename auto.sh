#!/bin/bash

# Function to check if MariaDB is installed
is_installed() {
  dpkg-query -l mariadb-server >/dev/null 2>&1
  return $?
}

# Update package lists
sudo apt update

# Set default root password (prompt before installation check)
echo "Enter the desired default root password for MariaDB:"
read -sr root_password

sudo mysql_secure_installation << EOF
Y
$root_password
$root_password
Y
Y
Y
EOF  

# Check if MariaDB is already installed
if is_installed; then
  echo "MariaDB is already installed."
  echo "Do you want to manage existing users (y/N): "
  read -r manage_users
  if [[ "$manage_users" =~ ^[Yy]$ ]]; then
    # Manage existing users
    manage_existing_users
  else
    exit 0
  fi
else
  # Install MariaDB
  echo "Installing MariaDB..."
  sudo apt install mariadb-server -y

  sudo systemctl start mariadb
  echo "Do you want to enable mariadb on boot (y/N): "
  read -r enabled
  if [[ "$enabled" =~ ^[Yy]$ ]]; then
    sudo systemctl enable mariadb
  fi
  echo "MariaDB installation complete."  # Exit after installation (recommended)
fi

# Function to manage existing users (unchanged)
manage_existing_users() {
  echo "Enter the number of users you want to create (0 to skip):"
  read -r num_users

  for (( i=1; i<=$num_users; i++ )); do
    echo "Enter username for user $i:"
    read -r username

    # Check if user already exists
    if mysql -u root -p$root_password -e "SELECT * FROM mysql.user WHERE User='$username'" >/dev/null 2>&1; then
      echo "User '$username' already exists."
      echo "Do you want to modify the password (y/N)?"
      read -r modify_password
      if [[ "$modify_password" =~ ^[Yy]$ ]]; then
        set_user_password $username
      fi
    else
      set_user_password $username
    fi
  done
}

# Function to set user password (with improved error handling)
set_user_password() {
  local username=$1
  echo "Enter a password for user '$username':"
  read -sr user_password

  # Create user with specific privileges (adjust as needed)
  local sql="GRANT CREATE, SELECT, INSERT, UPDATE, DELETE ON *.* TO '$username'@'%' IDENTIFIED BY '$user_password'; FLUSH PRIVILEGES;"

  # Execute the SQL statement and capture the output
  local result=$(mysql -u root -p$root_password -e "$sql" 2>&1)

  if [[ $? -eq 0 ]]; then
    echo "User '$username' created successfully."
  else
    echo "Error creating user '$username':"
    echo "$result"  # Print the error message from mysql
  fi
}

# This script stores the root password in plain text. Consider using
# environment variables or a password manager for improved security,
# especially in production environments.
