#!/bin/bash

# Define available configurations
configs=(
  "postfix"
  "apache2"
  "iperf"
  "mariadb"
  "nginx"
  "samba"
  "squid_proxy"
)

# Function to print available configurations
print_configs() {
  echo "Available configurations:"
  for i in "${!configs[@]}"; do
    echo -e "  $((i + 1)). ${configs[$i]}"
  done
}

print_configs

# Get user input
echo "Select configurations to install (enter number(s) separated by spaces or 'all' for all, or a range like '1-4'):"
read -r selections

# Check if user wants to install all
if [[ "$selections" == "all" ]]; then
  for config in "${configs[@]}"; do
    echo "Installing $config..."
    # Replace this line with the actual installation command for each configuration script
    ./${config}_config.sh  # Assuming installation scripts are named *_install.sh
  done
  exit 0
fi

# Validate user input
valid_selections=()
for selection in $selections; do
  # Check for range format (e.g., 1-4)
  if [[ $selection =~ ^[0-9]+-[0-9]+$ ]]; then
    start_num=${selection%%-*}
    end_num=${selection##-*}
    if [[ $start_num -gt 0 && $start_num -le ${#configs[@]} && $end_num -ge $start_num && $end_num -le ${#configs[@]} ]]; then
      for ((i=$start_num; i<=$end_num; i++)); do
        valid_selections+=("${configs[$(($i - 1))]}")
      done
    else
      echo "Invalid range: $selection. Please use a valid range (e.g., 1-4) within available options."
      exit 1
    fi
  # Check for individual number
  elif [[ $selection -gt 0 && $selection -le ${#configs[@]} ]]; then
    valid_selections+=("${configs[$(($selection - 1))]}")
  else
    echo "Invalid selection: $selection. Please enter valid number(s) separated by spaces, 'all', or a valid range (e.g., 1-4)."
    exit 1
  fi
done

if [[ ${#valid_selections[@]} -eq 0 ]]; then
  exit 1
fi

# Install selected configurations
for config in "${valid_selections[@]}"; do
  echo "Installing $config..."
  # Replace this line with the actual installation command for each configuration script
  sudo chmod +x ${config}_config.sh
  ./${config}_config.sh  # Assuming installation scripts are named *_install.sh
done

echo "Installation complete!"