#!/bin/bash

# Function to check if MariaDB is installed
is_installed() {
  # Check for `mariadb-server` package existence using a more robust approach
  if dpkg -l mariadb-server >/dev/null 2>&1; then
    return 0  # Indicate success
  else
    return 1  # Indicate failure
  fi
}
# Update package lists
sudo apt update

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
  if [[ "$enabled" =~ ^[Yy]$ ]]; then  # Add the closing parenthesis here
    # Enable MariaDB to start automatically at boot
    sudo systemctl enable mariadb

fi


# Set default root password
echo "Enter the desired default root password for MariaDB:"
read -sr root_password

# Secure MariaDB installation
sudo mysql_secure_installation << EOF
Y
$root_password
$root_password
Y
Y
Y
EOF

# Function to manage existing users
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

# Function to set user password
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

echo "MariaDB installation complete."
