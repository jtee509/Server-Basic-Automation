#!/bin/bash

# Operating System (Linux Distro) Requirements:
# Ubuntu Server 24.04
# Debian Based Distro

clear

echo " ____   __   _  _  ____   __      ___  __   __ _  ____  __  ___  "
echo "/ ___) / _\ ( \/ )(  _ \ / _\    / __)/  \ (  ( \(  __)(  )/ __) "
echo "\___ \/    \/ \/ \ ) _ (/    \  ( (__(  O )/    / ) _)  )(( (_ \ "
echo "(____/\_/\_/\_)(_/(____/\_/\_/   \___)\__/ \_)__)(__)  (__)\___/ "

# Update package lists (adjust for your package manager if needed)
sudo apt update

# Function to check if Samba is installed
is_samba_installed() {
  dpkg-query -l samba samba-common-tools >/dev/null 2>&1
  return $?
}

# Check if Samba is installed before proceeding
if is_samba_installed; then
  echo "Samba is installed. Do you want to reinstall again(y/N): "
  read -r reinstall 
  if [[ "$reinstall" =~ ^[Yy]$ ]]; then
    # Install Samba and additional tools (adjust as required)
    sudo apt install samba samba-common-tools
    break
  fi
else
  # Install Samba and additional tools (adjust as required)
  sudo apt install samba samba-common-tools
fi


sudo mkdir /etc/samba

clear

echo " ____   __   _  _  ____   __      ___  __   __ _  ____  __  ___  "
echo "/ ___) / _\ ( \/ )(  _ \ / _\    / __)/  \ (  ( \(  __)(  )/ __) "
echo "\___ \/    \/ \/ \ ) _ (/    \  ( (__(  O )/    / ) _)  )(( (_ \ "
echo "(____/\_/\_/\_)(_/(____/\_/\_/   \___)\__/ \_)__)(__)  (__)\___/ "


if [ -f /etc/samba/smb.conf ]; then
  sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
fi

# Create a basic Samba configuration file (/etc/samba/smb.conf)
echo "Creating smb.conf"
sudo touch /etc/samba/smb.conf

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


while true; do
  echo "
  
  "
  echo "
  
What type of file would you like to create :
  1 - Default Public (Read and Write access for all)
  2 - Default Private (Read only for users)
  3 - Custom File (custom files)
  4 - Quit

Type select the "

  read -r file_type

  if [[ "$file_type" == "done" ]]; then
     break
  fi

  case $file_type in
    1)
      echo "Enter the default public sharename (to keep 'Public_(with a number)' as a default name press Enter): "
      read -r sharename

      # Check if filename is empty or only contains whitespace
      if [[ -z "${sharename}" || -z "$(trim <<< "$sharename")" ]]; then
        sharename="Public_File_$((num_shares + 1))"
      fi

      public="yes"
      writeable="$write_access"
      
      echo "The file name will be stored by default under parent folder '/share'"
      echo "Do you want to change the main directory (y/N):"
      read -r options
      
      if [["$options" =~ ^[Yy]$ ]]; then
        while true; do
          echo "Enter the parent folder if there is a subfolder add a '/' next to it
for example 'parent_folder/sub_folder' :"
          read -r file_dir
        
          echo "The file name will be shared by default under parent folder is /'$file_dir'"
          echo "Confirm the change? (y/N):"
          read -r filechange

          if [[ "$filechange" =~ ^[Yy]$ ]]; then
            while true; do
              echo "Enter the name for this file:"
              read -r filename
              
              file="/'$filechange'/'$filename'"
              echo "The entire directory is under this '$file'"
              echo "Confirm the change? (y/N):"
              read -r filechange

              if [[ "$filechange" =~ ^[Yy]$ ]]; then
                  break
              fi
            done
            
            break
          
          fi        
        done
      else
        while true; do
          echo "Enter the name for this file:"
          read -r filename
          
          file="/share/'$filename'"
          echo "The entire directory is under this '$file'"
          echo "Confirm the change? (y/N):"
          read -r filechange

          if [[ "$filechange" =~ ^[Yy]$ ]]; then
              break
          fi
        done
       
      fi
      path="$file_dir"
      if [ ! -d "/'$file'" ]; then          
        echo "Directory'$file' doesn't exist. Create it? (y/N)"
        if [[ $create_dir =~ ^[Yy]$ ]]; then
          sudo mkdir -p $file  # -p creates parent directories if needed
          if [ $? -eq 0 ]; then
            echo "Directory created successfully."
            break
          else
            echo "Failed to create directory."
          fi
        fi
      fi 
    ;;

    2)
    ;;

    3)
    ;;

    *)
    ;;
  esac
  
  sudo cat << EOF >> /etc/samba/shares.conf
[$share_name]
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
done

sudo groupadd --system smbgroup 

sudo useradd --system -no-create-home --group smbuser --group smbgroup -s /bin/false smbuser

for i in "${path2[@]}"; do 
   # Set ownership and permissions for the share directory (adjust as needed)
   sudo chown root:smbgroup "$i"
   sudo chmod 750 "$i"
done


# Restart Samba
sudo systemctl restart smbd
sudo systemctl enable smbd
sudo systemctl restart nmbd
sudo systemctl enable nmbd