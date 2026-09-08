#!/bin/bash

set -e

DOMAIN=$1
DEPLOY_USER=bot

cd /var/www/$DOMAIN
sudo -u $DEPLOY_USER bash -lc "git pull"

echo "----------"
echo "✅ git pull"
echo "----------"

sudo -u $DEPLOY_USER bash -lc "nvm install"

echo "----------"
echo "✅ nvm install"
echo "----------"

sudo -u $DEPLOY_USER bash -lc "npm install"

echo "----------"
echo "✅ npm install"
echo "----------"

# Runs into memory issues
# sudo -u interflux bash -lc "npm run build"
sudo -u $DEPLOY_USER bash -lc "NODE_OPTIONS=--max-old-space-size=4096 npm run build"

echo "----------"
echo "✅ npm run build"
echo "----------"

sudo systemctl daemon-reload
sudo systemctl restart $DOMAIN
sudo systemctl status $DOMAIN --no-pager

echo "----------"
echo "✅ systemctl restart $DOMAIN"
echo "----------"