#!/bin/bash

# Update package lists
sudo apt update

# Install MariaDB server
sudo apt install mariadb-server -y

# Prompt user for desired root password
read -s -p "Enter a strong password for the root user: " root_password

# Validate root password strength using a complexity check (optional but recommended)
# You can implement a complexity check using tools like 'pwquality' or regular expressions
# if [[ ! "$(pwquality <<< "$root_password")" =~ ^[a-zA-Z0-9!@#$%^&*()\-_+={}|;':",<.>/?]+$ ]] ; then
#   echo "Error: Root password must contain a mix of uppercase, lowercase, numbers, and special characters."
#   exit 1
# fi

# Secure MariaDB installation using `mysql_secure_installation`
sudo mysql_secure_installation <<EOF
Y
$root_password
Y
Y
Y
EOF

# Function to create a MariaDB user with password
create_user_with_password() {
  local username="$1"
  local password="$2"

  # Validate username
  if [[ "$username" == "root" ]]; then
    echo "Error: Username cannot be 'root'."
    return 1
  fi

  # Create user with encrypted password
  sudo mysql -u root -p"$root_password" -e "CREATE USER '$username'@'localhost' IDENTIFIED BY PASSWORD '*'"
  sudo mysql -u root -p"$root_password" -e "GRANT ALL PRIVILEGES ON *.* TO '$username'@'localhost' WITH GRANT OPTION"
  echo "User '$username' created successfully."
}

# Get number of user accounts to create
read -p "Enter the number of user accounts you want to create: " num_users

# Loop to create users based on input
for (( i=1; i<=$num_users; i++ )); do
  read -p "Enter username for user $i: " username
  read -s -p "Enter password for user $i: " user_password

  create_user_with_password "$username" "$user_password" || exit 1
done

echo "MariaDB installation complete!"

