#!/bin/bash

set -eou pipefail

DOMAIN=$1
DEPLOY_USER=bot

echo "----------"
echo "SYSTEMD"
echo "----------"
echo "stop service"
sudo systemctl stop $DOMAIN
echo "✅"
echo "----------"
echo "delete symbolic link"
sudo rm /etc/systemd/system/$DOMAIN.service
echo "✅"
echo "----------"
echo "reload daemon"
sudo systemctl daemon-reload
echo "✅"
echo "----------"
echo "NGINX"
echo "----------"
echo "delete symbolic link"
sudo rm /etc/nginx/sites-enabled/$DOMAIN.conf
echo "✅"
echo "----------"
echo "test nginx"
sudo nginx -t
echo "✅"
echo "----------"
echo "restart nginx"
sudo systemctl restart nginx
echo "✅"
echo "----------"
echo "CERTBOT"
echo "----------"
echo "remove apex TLS certificate"
sudo certbot delete --cert-name $DOMAIN --non-interactive
echo "✅"
echo "----------"
echo "remove www TLS certificate"
sudo certbot delete --cert-name www.$DOMAIN --non-interactive
echo "✅"
echo "----------"
echo "test nginx (again)"
sudo nginx -t
echo "✅"
echo "----------"
echo "SSH"
echo "----------"
echo "removing private deploy key"
sudo rm /home/$DEPLOY_USER/.ssh/$DEPLOY_USER@$DOMAIN
echo "✅"
echo "----------"
echo "removing private deploy key"
sudo rm /home/$DEPLOY_USER/.ssh/$DEPLOY_USER@$DOMAIN.pub
echo "✅"
echo "----------"
echo "WWW"
echo "----------"
echo "delete codebase"
sudo rm -rf /var/www/$DOMAIN
echo "✅"
echo "----------"
echo "LOGS"
echo "----------"
echo "delete log rotation"
sudo rm -rf /etc/logrotate.d/$DOMAIN
echo "----------"
echo "delete logs"
sudo rm -rf /var/log/$DOMAIN
echo "✅"
echo "----------"
echo "NEXT STEPS"
echo "👉🏼 Remove related DNS records (A and AAAA)
echo "👉🏼 Remove related secrets from 1Password