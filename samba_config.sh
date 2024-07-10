#!/bin/bash

# Operating System (Linux Distro) Requirements:
# Ubuntu Server 24.04
# Debian Based Distro


# Update package lists (adjust for your package manager if needed)
sudo apt update

# Function to check if Samba is installed
is_samba_installed() {
  command -v smbd >/dev/null 2>&1
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


# Important: User Input Loop for Multiple Shares
# User Input Loop for Multiple Shares
path2=()
num_shares=0
while true; do
   # User Input for File Type and Permissions
   file_type=""
   write_access="yes"

   echo "What type of file would you like to create (1 - public, 2 - private, 3 - other)? (enter 'done' to finish)"
   read -r file_type

   if [[ "$file_type" == "done" ]]; then
     break
   fi

   while true; do
     echo "Do you want to allow write access to this file (y/n)?"
     read -r write_access1
     if [[ "$write_access1" =~ ^[Yy]$ ]]; then
       write_access="yes"
       break
     else
       write_access="no"
     fi
     echo "Invalid input. Please enter 1 (y) or 2 (N)."
   done

   case $file_type in
     1)
       share_name="Public_File_$((num_shares + 1))"
       public="yes"
       writeable="$write_access"
       # Prompt for directory path for public files
       while true; do
         echo "Enter the name for this file:"
         read -r file_dir
         # Optional: Validate directory path
          if [ ! -d "$file_dir" ]; then
            echo "Directory '$file_dir' doesn't exist. Create it? (y/N)"
            read -r create_dir
            if [[ $create_dir =~ ^[Yy]$ ]]; then
              sudo mkdir -p "~/share/'$file_dir'"  # -p creates parent directories if needed
              if [ $? -eq 0 ]; then
                echo "Directory created successfully."
                break
              else
                echo "Failed to create directory."
              fi
            fi
          fi
         echo "Invalid directory path. Please enter a valid directory."
       done
       path="$file_dir"
       ;;
     2)
       share_name="Private_File_$((num_shares + 1))"
       public="no"
       writeable="no"
       # Prompt for directory path for private files
       while true; do
         echo "Enter the directory path for this private file (absolute path recommended):"
         read -r file_dir
         # Optional: Validate directory path
         if [ -d "$file_dir" ]; then
           break
         fi
         echo "Invalid directory path. Please enter a valid directory."
       done
       path="$file_dir"
       ;;
     *)
       # Handle other file types (optional)
       echo "Unsupported file type. Please choose 1 (public) or 2 (private)."
       continue
       ;;
   esac

   sudo mkdir -p $path

   # Write Share Configuration to File
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


# Restart Samba services to apply the configuration
sudo systemctl restart smb nmb
echo "Samba installation and basic configuration complete."
echo ""

echo "Shares Folder :
"

ls -l /share

# Print shares.conf contents
echo "** Contents of /etc/samba/shares.conf **"
sudo cat /etc/samba/shares.conf

# Print list of shared files (assuming directory listing works)
echo "** List of Shared Files **"
for share in $(cat /etc/samba/shares.conf | grep -oP '(?<=path = ).*'); do
  if [ -d "$share" ]; then
    ls -l "$share"
  else
    echo "Skipping: $share (not a directory)"
  fi
done