#!/bin/bash

set -e

DOMAIN=$1
DEPLOY_USER=bot

echo "----------"
echo "cd /var/www/$DOMAIN"

cd /var/www/$DOMAIN

echo "✅"
echo "----------"
echo "git reset --hard"

sudo -u $DEPLOY_USER bash -lc "git reset --hard"

echo "✅"
echo "----------"
echo "git checkout production"

sudo -u $DEPLOY_USER bash -lc "git checkout production"

echo "✅"
echo "----------"
echo "git pull"

sudo -u $DEPLOY_USER bash -lc "git pull"

echo "✅"
echo "----------"
echo "nvm install"

sudo -u $DEPLOY_USER bash -lc "nvm install"

echo "✅"
echo "----------"
echo "npm install"

sudo -u $DEPLOY_USER bash -lc "npm install"

echo "✅"
echo "----------"
echo "npm run build"

# Runs into memory issues
# sudo -u interflux bash -lc "npm run build"
sudo -u $DEPLOY_USER bash -lc "NODE_OPTIONS=--max-old-space-size=4096 npm run build"

echo "----------"
echo "systemctl restart $DOMAIN"

sudo systemctl daemon-reload
sudo systemctl restart $DOMAIN
sudo systemctl status $DOMAIN --no-pager

echo "✅"