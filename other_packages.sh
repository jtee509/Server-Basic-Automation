#!/bin/bash

# This script is designed for Ubuntu Server and uses apt for package management.

echo "
 ____  ____  ____  _  _  ____  ____    ____   __   ____  __  ___       
/ ___)(  __)(  _ \/ )( \(  __)(  _ \  (  _ \ / _\ / ___)(  )/ __)      
\___ \ ) _)  )   /\ \/ / ) _)  )   /   ) _ (/    \\___ \ )(( (__       
(____/(____)(__\_) \__/ (____)(__\_)  (____/\_/\_/(____/(__)\___)      
  __  __ _  ____  ____  __   __    __     __  ____  __  __   __ _      
 (  )(  ( \/ ___)(_  _)/ _\ (  )  (  )   / _\(_  _)(  )/  \ (  ( \     
  )( /    /\___ \  )( /    \/ (_/\/ (_/\/    \ )(   )((  O )/    /     
 (__)\_)__)(____/ (__)\_/\_/\____/\____/\_/\_/(__) (__)\__/ \_)__)    

"

# Define an array of services to install
SERVICES=(
  "apache2"  # Web server
  "php"      # PHP for web development
  "postfix"  # Mail server (optional)
  "vsftpd"   # FTP server (optional)
  "fail2ban" # Intrusion detection (optional)
  "ufw"      # Firewall (optional)
  "nextcloud" #file sharing server

  # Database options
  "postgresql" # Alternative database server (optional)
  "mariadb"    # Another database option (optional)
  "mysql"      # Original MySQL option (optional)
  # File sharing
  "samba-common"  # Core Samba libraries for file sharing (optional)
  "nfs-kernel-server" # NFS file sharing server (optional)
  # Development tools
  "git"       # Version control system (optional)
  "python3"  # Python programming language (optional)
  "nodejs"    # Javascript runtime environment (optional)
  # Other servers
  "nginx"    # Another web server option (optional)
  "dhcp"      # DHCP server (optional)
  "ssh"       # Secure shell server (already installed on most systems)
  "squid"
  # In-memory data stores
  "redis"    # In-memory data store (optional)
  "memcached" # Another in-memory data store (optional)
  # Monitoring
  "monit"     # Process monitoring tool (optional)
  "htop"      # System monitor 
)

# Define custom configuration scripts
CUSTOM_CONFIGS=(
  "mysql"="mysql_config.sh"
  "samba"="samba_config.sh"
  "squid"="squid_proxy.sh"
  "apache2"="apache2_install.sh"
)

# Track successful and failed installations (initially empty)
SUCCESSFUL=()
FAILED=()

# Get user selection
read -p "
This are a few starters packages within the services it self. 
Select packages (numbers, ranges, or both separated by spaces) (e.g., 1-3 8 12-14): " SELECTION


# Function to check if a number is within a range (inclusive)
function in_range() {
  local num=$1
  local start=$2
  local end=$3
  [[ $num -ge $start && $num -le $end ]]
}

sudo apt-get update
sudo apt-get full-upgrade

# Loop through selected packages
for package in $SELECTION; do

  # Check if selection is a range
  if [[ $package =~ ^[0-9]+-[0-9]+$ ]]; then
    start=${package%%-*}
    end=${package##-*}
    # Validate range
    if [[ ! $start =~ ^[0-9]+$ || ! $end =~ ^[0-9]+$ || $start -gt $end ]]; then
      echo "Invalid range: $package"
      continue
    fi
    # Loop through packages in the range
    for ((i=$start; i<=$end; i++)); do
      process_package $i
    done
  # Check if selection is a single number
  elif [[ $package =~ ^[0-9]+$ ]]; then
    process_package $package
  else
    echo "Invalid selection: $package"
  fi
done

# Print successful and failed installations
echo "Successfully Installed Packages:"
echo "${SUCCESSFUL[@]}"

if [[ ${#FAILED[@]} -gt 0 ]]; then
  echo "Failed to Install Packages:"
  echo "${FAILED[@]}"
fi

# Function to process a selected package
function process_package() {
  local index=$(( $1 - 1 ))
  if [[ $index -lt 0 || $index -ge ${#SERVICES[@]} ]]; then
    echo "Invalid package number: $1"
    return
  fi

  echo "Installing: ${SERVICES[$index]}"

  # Install package using apt and capture exit code
  if sudo apt install "${SERVICES[$index]%:*}" &> /dev/null; then
    SUCCESSFUL+=("${SERVICES[$index]}")
  else
    FAILED+=("${SERVICES[$index]}")
    echo "  **Failed to install: ${SERVICES[$index]}"
  fi

  # Check for custom configuration script
  local config_script="${CUSTOM_CONFIGS[$index]}"
  if [[ ! -z "$config_script" ]]; then
    echo "Running custom configuration for ${SERVICES[$index]%:*}..."
    ./"$config_script"
  fi
}


echo "Thank you for using the this automation" 



