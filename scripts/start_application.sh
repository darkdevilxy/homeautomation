#!/bin/bash

cd /var/www/html

# Set verbose output for npm install
npm install --verbose

if [ $? -ne 0 ]; then
  echo "npm install failed. Check the logs for more details."
  exit 1
fi

npm start

if [ $? -ne 0 ]; then
  echo "npm start failed. Check the logs for more details."
  exit 1
fi

sudo systemctl restart nginx

if [ $? -ne 0 ]; then
  echo "Nginx restart failed. Check the system logs for more details."
  exit 1
fi

echo "Deployment successful!"