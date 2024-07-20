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
  "mariadb"="mysql_config.sh"
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

# Get user input
read -p "Enter the number(s) of the packages you want to install (e.g., 1-4 5 8 11-13): " choices

# Validate input
if ! validate_input "$choices"; then
  exit 1
fi

# Declare an empty array to store selected services
selected_services=()

# Loop through selected choices
for num in $choices; do
  # Check if number is within valid service range (1 to ${#SERVICES[@]})
  if [[ $num -ge 1 && $num -le ${#SERVICES[@]} ]]; then
    # Get the service name based on the index (num - 1)
    service="${SERVICES[$(($num - 1))]}"
    selected_services+=("$service")
  else
    echo "Warning: Skipping invalid selection: $num"
  fi
done

# Print selected services
echo "Selected services:"
printf '%s\n' "${selected_services[@]}"

# Loop through selected services and install
for service in "${selected_services[@]}"; do
  echo "Installing $service..."
  # Install the package using your preferred package manager (e.g., apt, yum)
  sudo apt install "$service"  # Replace with your package manager
  
  # Check if custom configuration script exists
  if [[ ${CUSTOM_CONFIGS[$service]} ]]; then
    config_script="${CUSTOM_CONFIGS[$service]}"
    echo "Running custom configuration script: $config_script"
    ./"$config_script"  # Assuming scripts are in the same directory
  fi
done

echo "Installation complete!"
