#!/bin/bash

# Define an array of services to install
SERVICES=(
  "apache2"  # Web server
  "php"       # PHP for web development
  "postfix"   # Mail server (optional)
  "vsftpd"    # FTP server (optional)
  "fail2ban"  # Intrusion detection (optional)
  "ufw"       # Firewall (optional)
  "nextcloud" # File sharing server
  "nginx"
  "nodejs"
  # Database options
  "postgresql" # Alternative database server (optional)
  "mariadb"   # Another database option (optional)
  # File sharing
  "samba-common"  # Core Samba libraries for file sharing (optional)
  "nfs-kernel-server" # NFS file sharing server (optional)
  # Development tools
  "git"        # Version control system (optional)
  "python3"    # Python programming language (optional)
  "nodejs"    # Javascript runtime environment (optional)
  # Other servers
  "nginx"      # Another web server option (optional)
  "dhcp"       # DHCP server (optional)
  "ssh"        # Secure shell server (already installed on most systems)
  "squid"
  # In-memory data stores
  "redis"  # In-memory data store (optional)
  "memcached" # Another in-memory data store (optional)
  # Monitoring
  "monit"  # Process monitoring tool (optional)
  "htop"   # System monitor
)

# Define custom configuration scripts
CUSTOM_CONFIGS=(
  "mariadb"="mariadb_config.sh"
  "samba-common"="samba_config.sh"
  "squid"="squid_proxy.sh"
  "apache2"="apache2_install.sh"
)

# Function to validate user input
function validate_input() {
  local input="$1"
  
  if [[ $input =~ ^[0-9]+(-[0-9]+)?([ ,]?[0-9]+)*$ ]]; then
    # Valid range or list of numbers
    return 0
  else
    echo "Invalid input. Please enter a range of numbers (e.g., 1-4) or a list of individual numbers (e.g., 1 3 5)."
    return 1
  fi
}

# Print available services with numbers
echo "Available Services:"
for (( i=0; i<${#SERVICES[@]}; i++ )); do
  service="${SERVICES[$i]}"
  echo "$(($i+1)). $service"
done

# Get user input
read -p "Enter the number(s) of the packages you want to install (e.g., 1-4 5 8 11-13): " choices

# Validate input
if ! validate_input "$choices"; then
  exit 1
fi

# ... rest of the script remains the same (logic for selecting and installing packages)
