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

cd /var/www/$DOMAIN

echo "----------"
echo "DATABASE"
echo "----------"
echo "drop database"
sudo -u $DEPLOY_USER bash -lc "rails db:drop"
echo "✅"
echo "----------"
echo "WWW"
echo "----------"
echo "delete codebase"
rm -rf /var/www/$DOMAIN
echo "✅"
echo "----------"
echo "LOGS"
echo "----------"
echo "delete logs"
rm -rf /var/log/$DOMAIN
echo "✅"

# echo "----------"
# echo "USERS"
# echo "----------"
# echo "remove Postgres user"
# NOTE: don't do this if this users is needed for other databases
# sudo -u postgres dropuser --if-exists $DEPLOY_USER
# echo "✅"
# echo "----------"
# echo "Stop services run by deploy user"
# sudo pkill -u "$DEPLOY_USER" || true
# echo "✅"
# echo "----------"
# echo "remove deploy user"
# NOTE: don't do this if this users is needed for deploying and running other apps
# sudo deluser --remove-home piccolo
# echo "✅"
# echo "----------"
# echo "remove deploy from all groups"
# sudo getent group piccolo
# sudo gpasswd -d www-data piccolo
# sudo delgroup piccolo
# echo "✅"
# echo "----------"
# echo "test nginx (again)"
# sudo nginx -t
# echo "✅"
# echo "----------"
# echo "restart nginx"
# sudo systemctl restart nginx
# echo "✅"

echo "----------"
echo "NEXT STEPS"
echo "👉🏼 Remove related DNS records (A and AAAA)
echo "👉🏼 Remove related secrets from 1Password