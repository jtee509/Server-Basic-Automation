#!/bin/bash

# Define an array of services to install
SERVICES=(
  "apache2"  # Web server
  "php"      # PHP for web development
  "postfix"  # Mail server (optional)
  "vsftpd"   # FTP server (optional)
  "fail2ban" # Intrusion detection (optional)
  "ufw"      # Firewall (optional)
  "nextcloud" #file sharing server
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
  "mariadb"="mysql_config.sh"
  "samba-common"="samba_config.sh"
  "squid"="squid_proxy.sh"
  "apache2"="apache2_install.sh"
)

# Function to install services
install_services() {
  for service in "$@"; do
    echo "Installing $service..."
    # Add installation command here, e.g. apt-get install $service
    # For this example, we'll just echo the installation command
    echo "sudo apt-get install -y $service"
  done
}

# Function to configure services
configure_services() {
  for service in "$@"; do
    if [[ ${CUSTOM_CONFIGS[$service]} ]]; then
      echo "Configuring $service..."
      # Add configuration command here, e.g. bash ${CUSTOM_CONFIGS[$service]}
      # For this example, we'll just echo the configuration command
      echo "bash ${CUSTOM_CONFIGS[$service]}"
    fi
  done
}

# Print the list of services
echo "Select services to install (e.g. 1-5, 19, 4 10-12):"
for i in "${!SERVICES[@]}"; do
  echo "  $i: ${SERVICES[$i]}"
done

read -p "Enter your selection: " selection

# Parse the selection
selected_services=()
for sel in $selection; do
  if [[ $sel =~ ^[0-9]+$ ]]; then
    selected_services+=("${SERVICES[$sel-1]}")
  elif [[ $sel =~ ^([0-9]+)-([0-9]+)$ ]]; then
    start=${BASH_REMATCH[1]}
    end=${BASH_REMATCH[2]}
    for ((i=start; i<=end; i++)); do
      selected_services+=("${SERVICES[$i-1]}")
    done
  fi
done

# Install and configure the selected services
install_services "${selected_services[@]}"
configure_services "${selected_services[@]}"