#!/bin/bash


sudo apt update -y
sudo apt upgrade -y

sudo apt install python3 -y
sudo apt install python3-pip -y 

# Define ports for each HTML file
PORT1=8000
PORT2=8080

# Get the current directory (where the script is located)
CURRENT_DIR=$(pwd)

# Define paths to HTML files (use relative paths based on current directory)
HTML1_PATH="$CURRENT_DIR/example1.html"
HTML2_PATH="$CURRENT_DIR/example2.html"

# Check if both HTML files exist
if [[ ! -f "$HTML1_PATH" || ! -f "$HTML2_PATH" ]]; then
  echo "Error: One or both HTML files not found!"
  exit 1
fi

# Start serving the first HTML on port $PORT1
python3 -m http.server $PORT1 $HTML1_HTML &
PID1=$!  # Capture process ID for first server

# Start serving the second HTML on port $PORT2
python3 -m http.server $PORT2 $HTML2_PATH &
PID2=$!  # Capture process ID for second server

# Print confirmation message and instructions
echo "Serving example1.html on port: $PORT1 (PID: $PID1)"
echo "Serving example2.html on port: $PORT2 (PID: $PID2)"
echo "To stop the servers manually, use the following command:"
echo "kill $PID1 $PID2"
