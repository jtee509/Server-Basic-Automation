#!/bin/bash

# Define available configurations
CONFIGS=(
  "Postfix (mail server)"
  "Apache2 (web server)"
  "iperf (network performance tool)"
  "MariaDB (database server)"
  "Nginx (web server)"
  "Samba (file sharing)"
  "Squid (web proxy server)"
)

# Function to print the menu
function print_menu {
  echo "Available Configurations:"
  for (( i=0; i<${#CONFIGS[@]}; i++ )); do
    echo -e "[$(($i+1))] - ${CONFIGS[$i]}"
  done
}

# Get user selection(s)
SELECTED_CONFIGS=()
while true; do
  print_menu
  read -p "Enter number(s) to select (separated by spaces, or 'q' to quit): " SELECTION

  # Check for quit option
  if [[ "$SELECTION" == "q" ]]; then
    break
  fi

  # Validate selection
  for num in $SELECTION; do
    if [[ ! "$num" =~ ^[1-9]+$ ]]; then
      echo "Invalid selection: '$num'"
      continue 2
    fi
    if [[ $num -le 0 || $num -gt ${#CONFIGS[@]} ]]; then
      echo "Invalid selection: '$num'"
      continue 2
    fi
    SELECTED_CONFIGS+=("${CONFIGS[$(($num-1))]}")
  done

  if [[ ${#SELECTED_CONFIGS[@]} -eq 0 ]]; then
    echo "No configurations selected."
  else
    echo "You selected: ${SELECTED_CONFIGS[@]}"
    break
  fi
done

# Run selected configurations
if [[ ${#SELECTED_CONFIGS[@]} -gt 0 ]]; then
  echo "Installing selected configurations..."
  for config in "${SELECTED_CONFIGS[@]}"; do
    # Replace 'config_name.sh' with the actual script name
    bash config_name.sh
  done
fi

echo "Done."

