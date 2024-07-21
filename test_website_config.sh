#!/bin/bash

# Define ports for each page
PORT1=8080
PORT2=8081

sudo apt-get install python3 -y

# Start simple HTTP servers for each page
python3 -m http.server $PORT1 page1.html &
python3 -m http.server $PORT2 page2.html &

# Wait for background processes to finish (optional)
# wait

echo "** Servers started!**"
echo " - Page 1: http://localhost:$PORT1/page1.html"
echo " - Page 2: http://localhost:$PORT2/page2.html"

# Display instructions on how to stop the servers (optional)
echo "** To stop the servers, press Ctrl+C in this terminal window. **"
