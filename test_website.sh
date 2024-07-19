#!/bin/bash

sudo apt update -y
sudo apt upgrade -y

sudo apt install python3 -y
sudo apt install python3-pip -y 

# Define ports for each HTML file
PORT1=8001
PORT2=8002

# Define paths to your HTML files
HTML_FILE1="example1.html"
HTML_FILE2="example2.html"

# Start servers in the background
python3 server.py $PORT1 $HTML_FILE1 &
python3 server.py $PORT2 $HTML_FILE2 &

# Print confirmation message
echo "Servers started:"
echo "  - http://localhost:$PORT1 - $HTML_FILE1"
echo "  - http://localhost:$PORT2 - $HTML_FILE2"