#!/bin/bash
sudo yum update -y
sudo yum install -y nodejs npm

sudo chown ec2-user:ec2-user /var/www/html
sudo chmod +x /var/www/html/scripts/start_application.sh