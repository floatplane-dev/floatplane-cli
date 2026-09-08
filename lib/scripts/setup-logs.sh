#!/bin/bash

set -e

DOMAIN=$1
DEPLOY_USER=bot
SUDO_USER=admin

# ACL

if command -v setfacl >/dev/null 2>&1; then
    echo "----------"
    echo "✅ ACL is already installed"
    echo "----------"
else
    echo "----------"
    echo "Installing ACL ..."
    echo "----------"
    # This command fails because Debian dropped support for our version
    # TODO: upgrade Debian
    # sudo apt -y update -qq
    sudo apt -y install acl
    echo "----------"
    echo "✅ ACL installed"
    echo "----------"
fi

# LOGS

# Rails, Puma, Nginx, Bullet and PM2 all should log to /var/log and not to log/ in domain root.

if [[ -d "/var/log/$DOMAIN" ]]; then
    echo "----------"
    echo "✅ /var/log/$DOMAIN already exists"
    echo "----------"
else
    echo "----------"
    echo "Creating /var/log/$DOMAIN"
    echo "----------"

    # Create directory for logging to
    sudo mkdir /var/log/$DOMAIN

    # Make the deploy user owner of the logs
    sudo chown -R $DEPLOY_USER:$DEPLOY_USER /var/log/$DOMAIN
    sudo chmod 775 /var/log/$DOMAIN

    # Grant admin access to the logs
    sudo setfacl -R -m u:$SUDO_USER:rwx /var/log/$DOMAIN/
    sudo setfacl -R -d -m u:$SUDO_USER:rwx /var/log/$DOMAIN/
    sudo getfacl /var/log/$DOMAIN/

    # Allow Nginx to also write logs
    sudo usermod -aG $DEPLOY_USER www-data
    sudo systemctl restart nginx

    # Never keeps logs older than 7 days
    sudo tee /etc/logrotate.d/$DOMAIN > /dev/null <<EOF
/var/log/$DOMAIN/*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    copytruncate
}
EOF

    echo "----------"
    echo "✅ Created /var/log/$DOMAIN"
    echo "----------"
fi