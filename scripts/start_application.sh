#!/bin/bash
cd /var/www/html

# Kill any existing node process
pkill node || true

# Install dependencies
npm install

# Start application in background and redirect output to log file
node index.js > /var/www/html/app.log 2>&1 &

# Save the process ID
echo $! > /var/www/html/app.pid

# Wait a few seconds to verify app started
sleep 5

# Check if process is running
if ps -p $(cat /var/www/html/app.pid) > /dev/null; then
    echo "Application started successfully"
    exit 0
else
    echo "Failed to start application"
    cat /var/www/html/app.log
    exit 1
fi