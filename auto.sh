#!/bin/bash

main(){
    # Update package lists
    sudo apt update
    
    mariadbinstall
    
    # Function to check if cnf file exists
    function cnf_exists() {
      if [ -f "$cnf_file" ]; then
        return 0  # True - file exists
      else
        return 1  # False - file doesn't exist
      fi
    }

    # Define configuration file path (optional, adjust if needed)
    cnf_file=~/.my.cnf

    # Check if cnf file exists
    if cnf_exists; then
      # Verify password in cnf file (assuming it's in the format shown below)
      cnf_password=$(grep -E "^password=.*$" "$cnf_file" | cut -d'=' -f2-)
      if ! sudo mysql -u root -p"$cnf_password" -e "SHOW DATABASES;" 2>/dev/null; then
        echo "Error: Existing cnf file might not contain the correct root password."
        echo "1. Enter the correct root password:"
        read -sr root_password
        # Update cnf file or create a new one with the correct password (secure)
        echo "[client]" > "$cnf_file"
        
        echo "user=root" >> "$cnf_file"
        echo "password=$root_password" >> "$cnf_file"
        chmod 600 "$cnf_file"
        echo "Updated cnf file with the provided password."
      else
        echo "Using existing cnf file for authentication."
      fi
    else
      # Prompt for password securely (hidden input) if cnf file doesn't exist
      echo "Enter the desired default MariaDB root password for MariaDB:"
      read -sr root_password

      # Create the cnf file with restricted permissions (more secure)
      echo "[client]" > "$cnf_file"
      echo "user=root" >> "$cnf_file"
      echo "password=$root_password" >> "$cnf_file"
      chmod 600 "$cnf_file"

      echo "Created cnf file: $cnf_file"
    fi

    # Now you can use mysql commands with the cnf file (more secure)
    sudo mysql --defaults-file="$cnf_file" -e "UPDATE mysql.user SET password='$root_password' WHERE User='root'; FLUSH PRIVILEGES;"

    # Optional: Unset the variable for security (if using the variable)
    # unset root_password

#    echo "Enter the desired default MariaDB root password for MariaDB (Press ENTER to keep it empty):"
#    read -sr root_password
#    
#    sudo mysql -u root -e "SET PASSWORD FOR root@'localhost' = PASSWORD('$root_password');"

    # Check for existing users
    echo "Checking for existing users..."
    clear 
    user_count=$(mysql -u root -p$root_password -e "SELECT COUNT(*) AS total_users FROM mysql.user" 2>/dev/null)

    # Extract the count (assuming the first line is the count)
    user_count=${user_count%% *}


    user_list=$(mysql -u root -p$root_password -e "SELECT User, Host FROM mysql.user" 2>/dev/null)

    if [[ $? -eq 0 ]]; then
      echo "These are the list of users: 
$user_list"    
      echo "
$user_count users found. Do you want to manage them (y/N): "
      read -r manage_users
      clear
    else
      echo "Error checking for users."
      exit 1
    fi
    
    if [[ "$manage_users" =~ ^[Yy]$ ]]; then
      # Manage users
      managing_users
    else
      exit 0
    fi
}

managing_users() {
  created_users=()  # List to store usernames of created users
  modified_users=()  # List to store usernames of modified users

  while true; do
    user_count=$(mysql -u root -p$root_password -e "SELECT COUNT(*) AS total_users FROM mysql.user" 2>/dev/null)

    # Extract the count (assuming the first line is the count)
    user_count=${user_count%% *}


    user_list=$(mysql -u root -p$root_password -e "SELECT User, Host FROM mysql.user" 2>/dev/null)

    if [[ $? -eq 0 ]]; then
      echo "These are the list of users: 
$user_list
"    
      echo "
$user_count users found.
"
    fi

    echo "Notice"
    echo "  To MODIFY the user please write the username (CASE SENSITIVE)"
    echo "  To CREATE a new user please write 'new'"
    echo "  To DELETE a user please write 'delete' followed by username (CASE SENSITIVE)"
    
    echo "Enter action (username, 'new', 'delete quit'):"
    read -r action username

    # Check for quit keyword
    if [[ "$action" == "quit" ]]; then
      break  # Exit the loop
    fi

    # Handle different actions
    case $action in
      new)
        set_user_password ""  # Create new user
        created_users+=("$username")
        ;;
      delete)
        if [[ -z "$username" ]]; then
          echo "Please provide username to delete."
        else
          delete_user "$username"
        fi
        ;;
      *)
        # Check if user exists for modify or unknown action
        if mysql -u root -p$root_password ping -h localhost -U "$action"; then
          username="$action"  # Update username for modify actions
          modify_user "$username"
          modified_users+=("$username")
        else
          echo "Invalid action or username '$action' does not exist."
        fi
        ;;
    esac

    clear
  done

  # Print user creation and modification summary
  echo "Created Users:
  "
  if [[ ${#created_users[@]} -gt 0 ]]; then
    for user in "${created_users[@]}"; do
      echo "- Username: $user
      "
    done
  else
    echo "- No users created."
  fi

  echo "Modified Users:
  "
  if [[ ${#modified_users[@]} -gt 0 ]]; then
    for user in "${modified_users[@]}"; do
      echo "- Username: $user"
    done
  else
    echo "- No users modified."
  fi
}


is_installed() {
  # Check if mariadb-server is installed
  dpkg-query -l mariadb-server >/dev/null 2>&1
  return $?
}


# Function to install MariaDB
mariadbinstall() {
  # Check if MariaDB is already installed
  if is_installed; then
    echo "MariaDB is already installed. Do you want to install it again? (y/N): "
    read -r reinstall
    if [[ "$reinstall" =~ ^[Yy]$ ]]; then
      sudo apt-get remove mariadb
      # Install MariaDB
      echo "Installing MariaDB..."
      sudo apt install mariadb-server -y

      sudo systemctl start mariadb
      echo "Do you want to enable mariadb on boot (y/N): "
      read -r enabled
      if [[ "$enabled" =~ ^[Yy]$ ]]; then
        sudo systemctl enable mariadb  
      fi
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
  fi
}

delete_user() {
  local username=$1
  echo "Are you sure you want to delete user '$username' (y/N)?"
  read -r confirm_delete
  if [[ "$confirm_delete" =~ ^[Yy]$ ]]; then
    local sql="DROP USER '$username'@'%';"
    local result=$(mysql -u root -p$root_password -e "$sql" 2>&1)
    if [[ $? -eq 0 ]]; then
      echo "User '$username' deleted successfully."
    else
      echo "Error deleting user '$username':"
      echo "$result"  # Print the error message from mysql
    fi
  fi
}

# New function to handle user modification actions
modify_user() {
  local username=$1
  echo "What do you want to modify for user '$username'?"
  echo "  1) Change Password"
  echo "  2) Change Username"
  echo "  Enter any other key to cancel"
  read -r modify_option

  case $modify_option in
    1)
      set_user_password "$username"
      ;;
    2)
      change_username "$username"
      ;;
    *)
      echo "Modification cancelled."
      ;;
  esac
}

change_username() {
  local username=$1
  local new_username

  while true; do
    echo "Enter a new username for user '$username':"
    read -r new_username

    # Check if username is empty
    if [[ -z "$new_username" ]]; then
      echo "Username cannot be empty."
      continue
    fi

    # Check if username already exists
    if mysql -u root -p$root_password ping -h localhost -U "$new_username"; then
      echo "Username '$new_username' already exists. Please choose another username."
    else
      # Update user with new username and privileges (replace with your actual update logic)
      local sql="RENAME USER '$username'@'%' TO '$new_username'@'%'; GRANT ALL PRIVILEGES ON *.* TO '$new_username'@'%' IDENTIFIED BY (SELECT password FROM mysql.user WHERE User='$username'); FLUSH PRIVILEGES;"
      local result=$(mysql -u root -p$root_password -e "$sql" 2>&1)
      if [[ $? -eq 0 ]]; then
        echo "Username for user '$username' changed to '$new_username' successfully."
        username="$new_username"  # Update username for further use
        break
      else
        echo "Error changing username for user '$username':"
        echo "$result"  # Print the error message from mysql
      fi
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


main "$@"; 

exit


# This script stores the root password in plain text. Consider using
# environment variables or a password manager for improved security,
# especially in production environments.