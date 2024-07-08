#!/bin/bash

main(){
    # Update package lists
    sudo apt update
    
    mariadbinstall

    echo "Enter the desired default MariaDB root password for MariaDB (Press ENTER to keep it empty):"
    read -sr root_password
    
    sudo mysql -u root -e "SET PASSWORD FOR root@'localhost' = PASSWORD('$root_password');"

    echo "Checking for existing users..."
    clear 
    # Define rows of the logo
    row1=" _  _  _  _  ____   __   __       ___  __   __ _  ____  __  ___  _  _  ____   __  ____  __  __   __ _  "
    row2="( \/ )( \/ )/ ___) /  \ (  )     / __)/  \ (  ( \(  __)(  )/ __)/ )( \(  _ \ / _\(_  _)(  )/  \ (  ( \ "
    row3="/ \/ \ )  / \___ \(  O )/ (_/\  ( (__(  O )/    / ) _)  )(( (_ \) \/ ( )   //    \ )(   )((  O )/    / "
    row4="\_)(_/(__/  (____/ \__\)\____/   \___)\__/ \_)__)(__)  (__)\___/\____/(__\_)\_/\_/(__) (__)\__/ \_)__) "

    # Print each row of the logo
    echo "$row1"
    echo "$row2"
    echo "$row3"
    echo "$row4"

    user_count=$(mysql -u root -p$root_password -e "SELECT COUNT(*) AS total_users FROM mysql.user" 2>/dev/null)

    # Extract the count (assuming the first line is the count)
    user_count=${user_count%% *}


    user_list=$(mysql -u root -p$root_password -e "SELECT User, Host FROM mysql.user" 2>/dev/null)

    if [[ $? -eq 0 ]]; then
      echo "
These are the list of users: 
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
  old_username=()
  new_username=()  # List to store usernames of modified users
  deleted_users=() 

  while true; do
    # Define rows of the logo
    row1=" _  _  _  _  ____   __   __       ___  __   __ _  ____  __  ___  _  _  ____   __  ____  __  __   __ _  "
    row2="( \/ )( \/ )/ ___) /  \ (  )     / __)/  \ (  ( \(  __)(  )/ __)/ )( \(  _ \ / _\(_  _)(  )/  \ (  ( \ "
    row3="/ \/ \ )  / \___ \(  O )/ (_/\  ( (__(  O )/    / ) _)  )(( (_ \) \/ ( )   //    \ )(   )((  O )/    / "
    row4="\_)(_/(__/  (____/ \__\)\____/   \___)\__/ \_)__)(__)  (__)\___/\____/(__\_)\_/\_/(__) (__)\__/ \_)__) "

    # Print each row of the logo
    echo "$row1"
    echo "$row2"
    echo "$row3"
    echo "$row4"
    user_count=$(mysql -u root -p$root_password -e "SELECT COUNT(*) AS total_users FROM mysql.user" 2>/dev/null)

    # Extract the count (assuming the first line is the count)
    user_count=${user_count%% *}


    user_list=$(mysql -u root -p$root_password -e "SELECT User, Host FROM mysql.user" 2>/dev/null)

    if [[ $? -eq 0 ]]; then
      echo "
These are the list of users: 
$user_list
"    
      echo "

$user_count users found.
"
    fi

    echo "Enter action (1: modify username, 2: create new user, 3: delete user, 4: quit):"
    read -r action

    # Check for quit option
    if [[ "$action" == "4" ]]; then
      break  # Exit the loop
    fi

    # Handle different actions using a case statement with numbers
    case $action in
      1)
        echo "Enter username to modify:"
        read -r username

        # Check if username is empty
        if [[ -z "$username" ]]; then
          echo "Username cannot be empty."
          continue
        fi
        
        # Check if user exists for modify
        if mysql -u root -p$root_password -e "SELECT 1 FROM mysql.user WHERE User='$username'" 2>/dev/null | grep -q "^1"; then
          old_username+=("$username")
          modify_user "$username"
          new_username+=("$username")
        else
          echo "Username '$username' does not exist. Do you want to create it (y/N): "
          read -r create
          if [[ "$create" =~ ^[Yy]$ ]]; then
            set_user_password "$username"  # Create new user
            # Assuming username is already defined elsewhere
            created_users+=("$username")
          fi
        fi
        ;;
      2)
        echo "Enter username to create:"
        read -r username

        # Check if username is empty
        if [[ -z "$username" ]]; then
          echo "Username cannot be empty."
          continue
        fi

        # Check if user exists for modify
        if mysql -u root -p$root_password -e "SELECT 1 FROM mysql.user WHERE User='$username'" 2>/dev/null | grep -q "^1"; then
          echo "Username '$username' does exist. Do you want to modify it (y/N): "
          read -r modify
          if [[ "$modify" =~ ^[Yy]$ ]]; then
            old_username+=("$username")
            modify_user "$username"
            new_username+=("$username")
          fi
        else
          set_user_password "$username"  # Create new user
          # Assuming username is already defined elsewhere
          created_users+=("$username")
        fi
        ;;
      3)
        echo "Enter username to delete:"
        read -r username

        # Check if username is empty
        if [[ -z "$username" ]]; then
          echo "Username cannot be empty."
          continue
        fi

        if [[ -z "$username" ]]; then
          echo "Please provide username to delete."
        else
          delete_user "$username"
          deleted_users+=("$username")
        fi
        ;;
      *)
        echo "Invalid action."
        ;;
    esac
    clear
  done

  clear

  echo "Thank you for using the system"
  echo "This are the list of users modified"

  # Print user creation and modification summary
  if [[ ${#created_users[@]} -gt 0 ]]; then
    for user in "${created_users[@]}"; do
      echo "Created Users:
      "
      echo "- Username: $user
      "
    done
  else
    echo "- No users created."
  fi

  if [[ ${#new_username[@]} -gt 0 ]]; then
    for ((i=0; i<${#new_username[@]}; ++i)); do
      echo "Modified Users:
      "
      # Assuming you have a way to get the corresponding old username for each new username
      old_user="${get_old_username[i]}"  # Replace with your logic to retrieve the old username
  
      # Add the old username to the 'old_username' array
      old_username+=("$old_user")
  
      echo "- Old Username: ${old_username[i]}"
      echo "- New Username: ${new_username[i]}"
      echo ""  # Add an empty line for better formatting
    done
  else
    echo "- No users modified."
  fi

  if [[ ${#deleted_users[@]} -gt 0 ]]; then
    for user in "${deleted_users[@]}"; do
      echo "Deleted Users:
      "
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
# Uncomment if you want to have enable options
#      echo "Do you want to enable mariadb on boot (y/N): "
#      read -r enabled
#      if [[ "$enabled" =~ ^[Yy]$ ]]; then
#        sudo systemctl enable mariadb  
#     fi
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
    if mysql -u root -p$root_password -e "SELECT COUNT(*) FROM mysql.user WHERE User='$new_username'" 2>/dev/null | grep -q "^1"; then
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