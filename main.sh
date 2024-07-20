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
CUSTOM_SERVICES=(
  "mariadb" 
  "samba-common" 
  "squid" 
  "apache2" 
)
CUSTOM_PACKAGES=(
  "mariadb_config.sh"
  "samba_config.sh"
  "squid_proxy.sh"
  "apache2_install.sh"
)

installed_packages=()
non_installed_packages=()

# Function to check if package is installed
is_installed() {
  dpkg -l | grep -q "^ii  $1 "
  return $?
}

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

# Process user choices - convert to service names
service_names=()
for choice in $choices; do
  # Check for range (e.g., 1-4)
  if [[ $choice =~ ^[0-9]+-[0-9]+$ ]]; then
    start=${choice%%-*}
    end=${choice##-*}
    for (( i=$start; i<=$end; i++ )); do
      service_names+=("${SERVICES[$(($i - 1))]}")  # Adjust index for 0-based array
    done
  else
    # Individual number (e.g., 5)
    service_names+=("${SERVICES[$(($choice - 1))]}")  # Adjust index for 0-based array
  fi
done

# Install chosen services
for service in "${service_names[@]}"; do
  if [[ " ${CUSTOM_SERVICES[@]} " =~ " $service " ]]; then
    # Use custom configuration script
    source ./${CUSTOM_PACKAGES[$(expr ${#CUSTOM_SERVICES[@]} - 1)]}  # Call the last matching script
  else
    # Basic installation using apt
    sudo apt install -y "$service"
    if [ $? -eq 0 ]; then
      installed_packages+=("$service")
    else
      non_installed_packages+=("$service")
    fi
  fi
done

# Print installation status
echo "Installed Packages: ${installed_packages[@]}"
echo "Non-Installed Packages: ${non_installed_packages[@]}"
