#!/bin/bash
cd /var/www/html
npm install
npm start

sudo systemctl restart nginx
