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

  # Add trap to handle termination (Ctrl+C) and ensure proper cleanup
  trap "kill $server_pid; echo '\nWebsite stopped on port $port'" EXIT

  # Detach the script from the terminal (optional, but recommended for long-running processes)
  disown
}

# Website directories (replace with your actual website directories)
website1_dir="example1.html"
website2_dir="example2.html"

# Choose appropriate ports (avoid conflicts with other processes)
website1_port=8000
website2_port=8001

# Start websites in the background
start_website "$website1_port" "$website1_dir"
start_website "$website2_port" "$website2_dir"

# Wait for both websites to finish (optional, if you want the script to remain running)
wait

echo "All websites stopped."
