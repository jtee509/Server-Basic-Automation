#!/bin/bash

# Operating System (Linux Distro) Requirements:
# Ubuntu Server 24.04
# Debian Based Distro

clear

echo " ____   __   _  _  ____   __      ___  __   __ _  ____  __  ___  "
echo "/ ___) / _\ ( \/ )(  _ \ / _\    / __)/  \ (  ( \(  __)(  )/ __) "
echo "\___ \/    \/ \/ \ ) _ (/    \  ( (__(  O )/    / ) _)  )(( (_ \ "
echo "(____/\_/\_/\_)(_/(____/\_/\_/   \___)\__/ \_)__)(__)  (__)\___/ "
echo "

"

# Update package lists (adjust for your package manager if needed)
sudo apt update -y
sudo apt upgrade -y

#!/bin/bash

# Package names for Samba server and tools
samba_package="samba"
samba_tools_package="samba-common"

# Check for existence of Samba packages
if dpkg query -l $samba_package $samba_tools_package >/dev/null 2>&1; then
  # Packages are installed
  echo "Samba and samba-common-tools are already installed."
  read -r -p "Would you like to reinstall them? (y/N): " reinstall

  if [[ $reinstall =~ ^[Yy]$ ]]; then
    # User confirms reinstallation
    echo "Removing existing Samba and samba-common-tools..."
    sudo apt remove -y $samba_package $samba_tools_package

    if [[ $? -eq 0 ]]; then
      echo "Reinstalling Samba and samba-common-tools..."
      sudo apt install -y $samba_package $samba_tools_package

      if [[ $? -eq 0 ]]; then
        echo "Samba and samba-common-tools successfully reinstalled."
      else
        echo "Error: Reinstallation failed."
        exit 1
      fi
    else
      echo "Error: Removal failed."
      exit 1
    fi
  else
    echo "Samba and samba-common-tools will remain installed."
  fi
else
  # Packages are not installed
  echo "Samba and samba-common-tools are not installed."
  echo "Installing Samba and samba-common-tools..."
  sudo apt install -y $samba_package $samba_tools_package

  if [[ $? -eq 0 ]]; then
    echo "Samba and samba-common-tools successfully installed."
  else
    echo "Error: Installation failed."
    exit 1
  fi
fi

sudo mkdir /etc/samba

clear

echo " ____   __   _  _  ____   __      ___  __   __ _  ____  __  ___  "
echo "/ ___) / _\ ( \/ )(  _ \ / _\    / __)/  \ (  ( \(  __)(  )/ __) "
echo "\___ \/    \/ \/ \ ) _ (/    \  ( (__(  O )/    / ) _)  )(( (_ \ "
echo "(____/\_/\_/\_)(_/(____/\_/\_/   \___)\__/ \_)__)(__)  (__)\___/ "
echo "
"


# Samba configuration file paths
conf_files=("/etc/samba/shares.conf" "/etc/samba/smb.conf")

# Backup directory (modify as needed)
backup_dir="/etc/samba/backups"

# Check if backup directory exists
if [ ! -d "$backup_dir" ]; then
  echo "Backup directory '$backup_dir' does not exist. Creating it..."
  sudo mkdir -p "$backup_dir"
fi

# Iterate through Samba configuration files
for conf_file in "${conf_files[@]}"; do
  # Check if file exists
  if [ -f "$conf_file" ]; then
    echo "
The configuration for this SAMBA installation consist of
TWO default file : 
- /etc/samba/shares.conf 
- /etc/samba/smb.conf

The following file existed:
$conf_file "

    # Ask for backup confirmation
    read -r -p "Do you want to back it up (its recommended that you back it up) (y/N): " backup

    if [[ $backup =~ ^[Yy]$ ]]; then
      # Create backup with timestamp
      backup_file="$conf_file.bak-$(date +%Y-%m-%d_%H-%M-%S)"
      sudo mv "$conf_file" "$backup_file"
      echo "Backup created: $backup_file"

      # Create a new empty touch file
      sudo touch "$conf_file"
      echo "New empty file created: $conf_file"
    else
      echo "Skipping backup for $conf_file."
    fi
  else
    echo "$conf_file does not exist."
  fi
done

# Create a temporary file for the configuration
temp_file=$(mktemp /tmp/samba_config.XXXXXX)

# Write the configuration to the temporary file
cat << EOF >> "$temp_file"
[global]
  workgroup = Group
  security = user
  map to guest = Bad User
  server signing = auto
  client signing = auto
  name resolve order = bcast host
  include = /etc/samba/shares.conf
  # Uncomment and set a strong password for security
  # security = share
  # map to guest = bad user
EOF

# Use sudo to copy the temporary file with correct permissions
sudo cp -p "$temp_file" /etc/samba/smb.conf


sudo touch /etc/samba/shares.conf


num_shares=0
temp_file_count=0
path2=()
# Create a temporary file for the configuration
temp_file1=$(mktemp /tmp/samba_config2.XXXXXX)

while true; do
  clear

  echo " ____   __   _  _  ____   __      ___  __   __ _  ____  __  ___  "
  echo "/ ___) / _\ ( \/ )(  _ \ / _\    / __)/  \ (  ( \(  __)(  )/ __) "
  echo "\___ \/    \/ \/ \ ) _ (/    \  ( (__(  O )/    / ) _)  )(( (_ \ "
  echo "(____/\_/\_/\_)(_/(____/\_/\_/   \___)\__/ \_)__)(__)  (__)\___/ "
  echo "
  "
  echo "
Samba will be configured manually in custom here are a few selections
that you can select. You can modify the following file configurations
as for each of the share types you created:
-read 
-public
-share name
-write
-file location

This few options has 2 default configuration and 1 custom files
you may pick which one you would like to create.

The global configuration has been imposed on a seperate file :
'/etc/samba/smb.conf'

The current configuration will be under this file:
'/etc/samba/shares.conf'
  
What type of file would you like to create :
  1 - Default Public (Read and Write access for all)
  2 - Default Private (Read only for all)
  3 - Custom File (custom files)
 
"
  read -r -p "Choose an option (to quit press '4'): " file_type
   

  if [[ "$file_type" == "4" ]]; then
     break
  fi

  case $file_type in
    1)
      echo "Enter the default public sharename (to keep 'Public_(with a number)' as a default name press Enter): " 
      read -r sharename

      # Check if filename is empty or only contains whitespace
      if [[ -z "${sharename}" || -z "${sharename##*[![:space:]]}" ]]; then        
        sharename="Public_File_$((num_shares + 1))"
      fi

      public="yes"
      writeable="yes"
      
      echo "The file name will be stored by default under parent folder '/share'"
      read -r -p "Do you want to change the main parent directory (y/N): " options


      if [[ "$options" =~ ^[Yy]$ ]]; then
        while true; do
          read -r -p "Enter the parent folder with the share folder 
if there is a subfolder add a '/' next to it
for example '/parent_folder/sub_folder/share_folder' or '/parent_folder/share_folder': " file_dir
        
          echo "The file name will be shared by default folder is '$file_dir'"
          read -r -p "Confirm the change? (y/N): " filechange 

          if [[ "$filechange" =~ ^[Yy]$ ]]; then
            if [ ! -d "$file_dir" ]; then
              sudo mkdir -p "$file_dir"
              if [ $? -eq 0 ]; then
                echo "Directory created successfully."
              else
                echo "Failed to create directory."
              fi
            fi
            break
          fi       
        done
      else
        while true; do
          read -r -p "Enter the name for this file you want to share under '/share' parent directory
if there is a subfolder add a '/' next to it
example input 'sub_folder/share_folder' or 'share_folder': " filename
          
          file_dir="/share/$filename"
          echo "The entire directory is under this '$file_dir'"
          read -r -p "Confirm the change? (y/N): " filechange

          if [[ "$filechange" =~ ^[Yy]$ ]]; then
            if sudo -E mkdir -p "$file_dir"; then  # Use `-E` to preserve environment variables
              echo "Directory created successfully."
            else
              if [ $? -eq 13 ]; then  # Check for permission error (code 13)
                echo "Error: Insufficient permissions to create directory."
              else
                echo "Failed to create directory."
              fi
            fi
            break
          fi

        done
       
      fi
      #marking the path directory
      path="$file_dir"
    ;;

    2)
      echo "Enter the default private sharename (to keep 'Private_(with a number)' as a default name press Enter): " 
      read -r sharename
      
      # Check if filename is empty or only contains whitespace
      if [[ -z "${sharename}" || -z "${sharename##*[![:space:]]}" ]]; then        
        sharename="Private_File_$((num_shares + 1))"
      fi

      public="yes"
      writeable="no"
      
      echo "The file name will be stored by default under parent folder '/share'"
      read -r -p "Do you want to change the main parent directory (y/N): " options
      
      if [[ "$options" =~ ^[Yy]$ ]]; then
        while true; do
          read -r -p "Enter the parent folder with the share folder 
if there is a subfolder add a '/' next to it
for example '/parent_folder/sub_folder/share_folder' or '/parent_folder/share_folder': " file_dir

          echo "The file name will be shared by default folder is '$file_dir'"
          read -r -p "Confirm the change? (y/N): " filechange
          

          if [[ "$filechange" =~ ^[Yy]$ ]]; then
            if [ ! -d "$file_dir" ]; then
              sudo mkdir -p "$file_dir"
              if [ $? -eq 0 ]; then
                echo "Directory created successfully."
              else
                echo "Failed to create directory."
              fi
            fi
            break
          fi       
        done
      else
        while true; do
          read -r -p "Enter the name for this file you want to share under '/share' parent directory
if there is a subfolder add a '/' next to it
example input 'sub_folder/share_folder' or 'share_folder': " filename
          
          file_dir="/share/$filename"
          echo "The entire directory is under this '$file_dir'"
          read -r -p "Confirm the change? (y/N): " filechange

          if [[ "$filechange" =~ ^[Yy]$ ]]; then
            if sudo -E mkdir -p "$file_dir"; then  # Use `-E` to preserve environment variables
              echo "Directory created successfully."
            else
              if [ $? -eq 13 ]; then  # Check for permission error (code 13)
                echo "Error: Insufficient permissions to create directory."
              else
                echo "Failed to create directory."
              fi
            fi
            break
          fi


        done
       
      fi
      #marking the path directory
      path="$file_dir"
    ;;

    3)
      echo "Enter the default custom sharename (to keep 'Custom_(with a number)' as a default name press Enter): " 
      read -r sharename

      # Check if filename is empty or only contains whitespace
      if [[ -z "${sharename}" || -z "${sharename##*[![:space:]]}" ]]; then        
        sharename="Custom_File_$((num_shares + 1))"
      fi

      read -r -p "Do you want it to be public (Y/n): " publicChoice
       
      if [[ $publicChoice =~ ^[Nn]$ ]]; then
        public="no"
      else
        public="yes"
      fi

      read -r -p "Do you want it to be writable (Y/n): " writeChoice

      if [[ $writeChoice =~ ^[Nn]$ ]]; then
        writeable="no"
      else
        writeable="yes"
      fi 
      
      echo "The file name will be stored by default under parent folder '/share'"
      read -r -p "Do you want to change the main parent directory (y/N): " options
      
      if [[ "$options" =~ ^[Yy]$ ]]; then
        while true; do
          echo "Enter the parent folder with the share folder 
if there is a subfolder add a '/' next to it
for example '/parent_folder/sub_folder/share_folder' or '/parent_folder/share_folder': "
          read -r file_dir
        
          echo "The file name will be shared by default folder is '$file_dir'"
          read -r -p "Confirm the change? (y/N): " filechange

          if [[ "$filechange" =~ ^[Yy]$ ]]; then
            if [ ! -d "$file_dir" ]; then
              sudo mkdir -p "$file_dir"
              if [ $? -eq 0 ]; then
                echo "Directory created successfully."
              else
                echo "Failed to create directory."
              fi
            fi
            break
          fi       
        done
      else
        while true; do
          read -r -p  "Enter the name for this file you want to share under '/share' parent directory
if there is a subfolder add a '/' next to it
example input 'sub_folder/share_folder' or '/share_folder': " filename
          
          file_dir="/share/$filename"
          echo "The entire directory is under this '$file_dir'"
          read -r -p "Confirm the change? (y/N): " filechange

          if [[ "$filechange" =~ ^[Yy]$ ]]; then
            if sudo -E mkdir -p "$file_dir"; then  # Use `-E` to preserve environment variables
              echo "Directory created successfully."
            else
              if [ $? -eq 13 ]; then  # Check for permission error (code 13)
                echo "Error: Insufficient permissions to create directory."
              else
                echo "Failed to create directory."
              fi
            fi
            break
          fi

        done
       
      fi
      #marking the path directory
      path="$file_dir"
    ;;

    *)
    ;;
  esac

  # Write configuration for this share to the temporary file
cat << EOF >> "$temp_file1"

[$sharename]
  path = $path
  force user = smbuser
  force group = smbgroup
  browseable = yes
  read only = no
  create mask = 0664
  force create mode = 0664
  directory mask = 0775 #new created files will have read and write
  force directory mode = 0775

  # Adjust permissions based on write access choice
  writeable = $writeable

  public = $public
  # Uncomment for encrypted communication (recommended)
  # encrypt passwords = yes
  # Add additional share definitions and options here
EOF

  path2+=($path)
   # Increment counter for share naming
  ((num_shares++))
  clear
done

# Use sudo to copy the temporary file with correct permissions
sudo cp -p "$temp_file1" /etc/samba/shares.conf

# User and group names
user_name="smbuser"
group_name="smbgroup"

# Check for group existence
if ! getent group $group_name >/dev/null 2>&1; then
  echo "Group '$group_name' does not exist. Creating it..."
  sudo groupadd --system $group_name
fi

# Check for user existence
if ! id -u $user_name >/dev/null 2>&1; then
  echo "User '$user_name' does not exist. Creating it..."
  sudo useradd --system --no-create-home --group $group_name -s /bin/false $user_name
fi

clear

echo " ____   __   _  _  ____   __      ___  __   __ _  ____  __  ___  "
echo "/ ___) / _\ ( \/ )(  _ \ / _\    / __)/  \ (  ( \(  __)(  )/ __) "
echo "\___ \/    \/ \/ \ ) _ (/    \  ( (__(  O )/    / ) _)  )(( (_ \ "
echo "(____/\_/\_/\_)(_/(____/\_/\_/   \___)\__/ \_)__)(__)  (__)\___/ "

echo "

/etc/samba/smb.conf file output : 

"

sudo cat /etc/samba/smb.conf

echo "

/etc/samba/shares.conf file output : 

"

sudo cat /etc/samba/shares.conf


echo "

Here is the all the configuration made above
You may reconfigure on later if you do want to editing the file below
using the 'sudo nano /etc/samba/shares.conf' commmand.

NOTICE : 
All the files within the configuration are under ROOT ownership.
DO NOT change the ownership!! 

The following ports have been allowed through UFW configuration:
80
443
445
"

for i in "${path2[@]}"; do 
   # Set ownership and permissions for the share directory (adjust as needed)
   sudo chown smbuser:smbgroup "$i"
   sudo chmod 750 "$i"
done

# Restart Samba
sudo systemctl restart smbd
sudo systemctl restart nmbd



sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 445

sudo ufw disable
sudo ufw enable

