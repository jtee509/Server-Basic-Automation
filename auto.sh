#!/bin/bash

# Function to check if MariaDB is installed
is_installed() {
  dpkg-query -l mariadb-server >/dev/null 2>&1
  return $?
}

# Update package lists
sudo apt update


# Try connecting with an empty password
if mysql -u root >/dev/null 2>&1; then
  echo "WARNING: MariaDB root user seems to be accessible without a password."
  echo "Enter the desired default root password for MariaDB (Press ENTER to keep it empty):"
  read -sr root_password
else
  echo "MariaDB root user has already a password for access."
  echo "Do you want to reset the password (y/N) :"
  read -r password
  if [[ "$password" =~ ^[Yy]$ ]]; then
    echo "Enter the desired default root password for MariaDB (Press ENTER to keep it empty):"
    read -sr root_password1
    mysql -u root -e "SET PASSWORD FOR root@'localhost' = PASSWORD('$root_password1');"
  fi
fi

# Only attempt to modify terminal settings if interactive
[[ $- == *i* ]] && stty -echo  # Silence password echo (if interactive)



echo $root_password | sudo mariadb_secure_installation << EOF
Y
$root_password
$root_password
Y
Y
Y
EOF

# Restore terminal settings if modified
[[ $- == *i* ]] && stty echo  # Restore echo (if interactive)


# Check if MariaDB is already installed
if is_installed; then
  echo "MariaDB is already installed."

  # Check for existing users
  echo "Checking for existing users..."
  user_count=$(mysql -u root -p$root_password -e "SELECT COUNT(*) FROM mysql.user" 2>/dev/null)

  if [[ $? -eq 0 ]]; then
    if [[ $user_count -eq 0 ]]; then
      echo "No users found. Proceed with creating new users? (y/N)"
      read -r manage_users
    else
      echo "$user_count users found. Do you want to manage them (y/N): "
      read -r manage_users
    fi
  else
    echo "Error checking for users."
    exit 1
  fi

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