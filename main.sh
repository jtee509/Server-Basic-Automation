#!/bin/bash

# Define an array of services to install
SERVICES=(
  "apache2"  # Web server
  "php"      # PHP for web development
  "postfix"  # Mail server (optional)
  "vsftpd"   # FTP server (optional)
  "fail2ban" # Intrusion detection (optional)
  "ufw"      # Firewall (optional)
  "nextcloud" # File sharing server
  "nginx" 
  "nodejs" 
  # Database options
  "postgresql" # Alternative database server (optional)
  "mariadb"    # Another database option (optional)
  # File sharing
  "samba-common"  # Core Samba libraries for file sharing (optional)
  "nfs-kernel-server" # NFS file sharing server (optional)
  # Development tools
  "git"       # Version control system (optional)
  "python3"  # Python programming language (optional)
  # Other servers
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
  "mariadb"
  "samba-common" 
  "squid" 
  "apache2" 
)

CUSTOM_PACKAGES=(
  "mysql_config.sh"
  "samba_config.sh"
  "squid_proxy.sh"
  "apache2_install.sh"
)

# Display services to the user
echo "Available services:"
for (( i=0; i<${#SERVICES[@]}; i++ )); do
  echo "  $((i+1)). ${SERVICES[i]}"
done

# Function to validate user input
function validate_input() {
  local input="$1"
  
  # Check if input is empty
  if [[ -z "$input" ]]; then
    echo "Invalid input. Please enter a selection."
    return 1
  fi
  
  # Check for valid characters (numbers, hyphens, and spaces)
  if [[! "$input" =~ ^[0-9 -]+$ ]]; then
    echo "Invalid input. Use numbers, hyphens (-), and spaces."
    return 1
  fi
  return 0
}

# Get user input for services
read -p "Enter service numbers (e.g., 1-5 19 4 10-12): " selection

# Validate user input
if! validate_input "$selection"; then
  exit 1
fi

# Loop through user selection
IFS=" " read -r -a choices <<< "$selection"

# Function to install service
function install_service() {
  local service="$1"
  echo "Installing service: $service"
  
  # Use your preferred package manager here (e.g., apt, yum)
  # Replace with the appropriate command for your system
  sudo apt install "$service" -y

  # Check if custom configuration script exists
  for (( i=0; i<${#CUSTOM_CONFIGS[@]}; i++ )); do
    if [[ "${CUSTOM_CONFIGS[i]}" == "$service" ]]; then
      local config_script="${CUSTOM_PACKAGES[i]}"
      echo "Running custom configuration script: $config_script"
     ./"$config_script"
    fi
  done
}

# Install selected services
for choice in "${choices[@]}"; do
  # Check for range selection
  if [[ $choice =~ ^[0-9]+-[0-9]+$ ]]; then
    # Extract start and end numbers from range
    start=${choice%%-*}
    end=${choice##*-}
    
    # Loop through the range and install services
    for (( i=$start; i<=$end; i++ )); do
      if [[ $i -le ${#SERVICES[@]} ]]; then
        install_service "${SERVICES[i-1]}"
      else
        echo "Skipping invalid service number: $i"
      fi
    done
  else
    # Install specific service by index
    if [[ $choice -le ${#SERVICES[@]} ]]; then
      install_service "${SERVICES[choice-1]}"
    else
      echo "Skipping invalid service number: $choice"
    fi
  fi
done

echo "Installation complete!"