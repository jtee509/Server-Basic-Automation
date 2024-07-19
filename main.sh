#!/bin/bash

# This script is designed for Ubuntu Server and uses apt for package management.

# Define an array of services to install
SERVICES=(
  "apache2"  # Web server
  "php"      # PHP for web development
  "postfix"  # Mail server (optional)
  "vsftpd"   # FTP server (optional)
  "fail2ban" # Intrusion detection (optional)
  "ufw"      # Firewall (optional)
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
  # In-memory data stores
  "redis"    # In-memory data store (optional)
  "memcached" # Another in-memory data store (optional)
  # Monitoring
  "monit"     # Process monitoring tool (optional)
)

# Define custom configuration scripts
CUSTOM_CONFIGS=(
  "mysql"="mysql_config.sh"
  "samba"="samba_config.sh"
)

# Get user selection
read -p "Select packages (numbers, ranges, or both separated by spaces) (e.g., 1-3 8 12-14): " SELECTION

# Function to check if a number is within a range (inclusive)
function in_range() {
  local num=$1
  local start=$2
  local end=$3
  [[ $num -ge $start && $num -le $end ]]
}

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

# Function to process a selected package
function process_package() {
  local index=$(( $1 - 1 ))
  if [[ $index -lt 0 || $index -ge ${#SERVICES[@]} ]]; then
    echo "Invalid package number: $1"
    return
  fi

  echo "Installing: ${SERVICES[$index]}"
  # Install package using apt
  sudo apt install "${SERVICES[$index]%:*}"  # Remove description for package name

  # Check for custom configuration script
  local config_script="${CUSTOM_CONFIGS[$index]}"
  if [[ ! -z "$config_script" ]]; then
    echo "Running custom configuration for ${SERVICES[$index]%:*}..."
    ./"$config_script"
  fi
}
