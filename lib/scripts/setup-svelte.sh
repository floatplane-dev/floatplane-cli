#!/bin/bash

set -e

domain=$1

echo "----------"
echo "Setting up Svelte Kit ⚡️"
echo "----------"
echo "cd /var/www/$domain"
cd /var/www/$domain
echo "----------"

grep -qE "from\s*['\"]@sveltejs/adapter-node['\"]" svelte.config.* || {
    echo "❌ adapter-node is not the default adaptor" >&2
    exit 1
}

[[ -f pm2.config.js ]] || {
    echo "❌ pm2.config.js is missing" >&2
    exit 1
}

if [ -f ".env.example" ]; then
  echo "----------"
  echo "Enter .env.production in this format:"
  echo $(cat .env.example)
  echo "----------"
  read env_vars
  echo "----------"
  echo $env_vars >> .env.production
  echo "✅ .env.production created"
fi

# BUILD

echo "----------"
echo "nvm install"
sudo -u $deploy bash -lc 'nvm install'
echo "----------"
echo "npm install"
sudo -u $deploy bash -lc 'npm install'
echo "----------"
echo "npm run build"
sudo -u $deploy bash -lc 'npm run build'

# DAEMON

echo "----------"
echo "Configuring daemon"
sudo ln -s /var/www/$domain/systemd.service /etc/systemd/system/$domain.service
sudo systemctl daemon-reload
echo "✅ Done"
echo "----------"
echo "Starting daemon"
sudo systemctl stop $domain
sudo systemctl start $domain
sudo systemctl status $domain --no-pager
echo "✅ Done"