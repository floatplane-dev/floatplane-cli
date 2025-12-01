#!/bin/bash

set -e

domain=$1
deploy=$2

# LOGS

# Rails, Puma, Nginx and Bullet should log to /var/log and not log/ in Rails root.

# Create directory for logging to
sudo mkdir /var/log/$domain

# Make the deploy user owner of the logs
sudo chown -R $deploy:$deploy /var/log/$domain
sudo chmod 775 /var/log/$domain

# Allow Nginx to also write to this directory
sudo usermod -aG $deploy www-data
sudo systemctl restart nginx

# Never keeps logs older than 7 days
sudo tee /etc/logrotate.d/$domain > /dev/null <<EOF
/var/log/$domain/*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    copytruncate
}
EOF