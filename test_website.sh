#!/bin/bash

# Function to start a website
start_website() {
  port="$1"
  website_dir="$2"

  # Error handling for invalid port number (outside 1-65535 range)
  if [[ $port -lt 1 || $port -gt 65535 ]]; then
    echo "Error: Invalid port number $port. Please choose a port between 1 and 65535."
    exit 1
  fi

  # Start the Python server in the background
  python3 -m http.server "$port" -d "$website_dir" &
  server_pid=$!

  # Print server information with clear formatting
  echo "Website started on port $port (directory: $website_dir)"
}

# Website directories (replace with your actual paths)
website1_dir="/Server-Basic-Automation/example1.html"
website2_dir="/Server-Basic-Automation/example2.html"

# Choose appropriate ports (avoid conflicts with other processes)
website1_port=8000
website2_port=8001

# Start websites in the background
start_website "$website1_port" "$website1_dir"
start_wrapper "$website2_port" "$website2_dir"

# Keep the script running indefinitely
while true; do
  sleep 60  # Optional: Add a sleep here to avoid busy waiting (adjust as needed)
done
