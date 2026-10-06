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
echo "rbenv install --skip-existing"

sudo -u $DEPLOY_USER bash -lc "rbenv install --skip-existing"

echo "✅"
echo "----------"
echo "bin/bundle install"

sudo -u $DEPLOY_USER bash -lc "bin/bundle install"

echo "✅"
echo "----------"
echo "bin/rails db:migrate"

sudo -u $DEPLOY_USER bash -lc "bin/rails db:migrate"

echo "✅"
echo "----------"
echo "systemctl restart $DOMAIN"

sudo systemctl daemon-reload
sudo systemctl restart $DOMAIN
sudo systemctl status $DOMAIN --no-pager

echo "✅"