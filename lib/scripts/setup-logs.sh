#!/bin/bash

set -e

domain=$1
deploy=$2

# LOGS

# Rails, Puma, Nginx, Bullet and PM2 all should log to /var/log and not to log/ in project root.

if [[ -d "/var/log/$domain" ]]; then
    echo "----------"
    echo "✅ /var/log/$domain already exists"
    echo "----------"
else
    echo "----------"
    echo "Creating /var/log/$domain"
    echo "----------"

    # Create directory for logging to
    sudo mkdir /var/log/$domain

    # Make the deploy user owner of the logs
    sudo chown -R $deploy:$deploy /var/log/$domain
    sudo chmod 775 /var/log/$domain

    # Grant admin access to the logs
    sudo setfacl -R -m u:admin:rwx /var/log/$domain/
    sudo setfacl -R -d -m u:admin:rwx /var/log/$domain/
    sudo getfacl /var/log/$domain/

    # Allow Nginx to also write logs
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

    echo "----------"
    echo "✅ Created /var/log/$domain"
    echo "----------"
fi