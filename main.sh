#!/bin/bash

# Define available configurations
configs=(
  "Postfix"
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
echo "Select configurations to install (enter number(s) separated by spaces or 'all' for all):"
read -r selections

# Check if user wants to install all
if [[ "$selections" == "all" ]]; then
  for config in "${configs[@]}"; do
    echo "Installing $config..."
    # Replace this line with the actual installation command for each configuration script
    ./${config}_install.sh  # Assuming installation scripts are named *_install.sh
  done
  exit 0
fi

# Validate user input
valid_selections=()
for selection in $selections; do
  if [[ $selection -gt 0 && $selection -le ${#configs[@]} ]]; then
    valid_selections+=("${configs[$(($selection - 1))]}")
  fi
done

if [[ ${#valid_selections[@]} -eq 0 ]]; then
  echo "Invalid selection(s). Please enter valid number(s) or 'all'."
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
