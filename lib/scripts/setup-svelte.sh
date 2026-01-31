#!/bin/bash

set -e

domain=$1
deploy=$2

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

if [[ ! -f /var/www/"$domain"/systemd.service ]]; then
    echo "❌ systemd.service does not exist" >&2
    exit 1
fi

if [ -f ".env.example" ] && [ ! -f ".env.production" ]; then
  echo "----------"
  echo "Creating .env.production ..."
  echo "----------"
  echo "Enter production secrets in the format below:"
  echo $(cat .env.example)
  echo "----------"
  read env_vars
  echo "----------"
  echo $env_vars > .env.production
  sudo chown $deploy:$deploy .env.production
  echo "----------"
  echo "✅ .env.production created"
  echo "----------"

else
  echo "----------"
  echo "✅ .env.production already exists"
  echo "----------"
fi

# BUILD

echo "git pull"
sudo -u $deploy bash -lc "cd /var/www/$domain; git pull"
echo "✅ Done"
echo "----------"
echo "nvm install"
sudo -u $deploy bash -lc "cd /var/www/$domain; nvm install"
echo "✅ Done"
echo "----------"
echo "npm install"
sudo -u $deploy bash -lc "cd /var/www/$domain; npm install"
echo "✅ Done"
echo "----------"
echo "npm run build"
sudo -u $deploy bash -lc "cd /var/www/$domain; npm run build"
echo "✅ Done"
echo "----------"

# DAEMON

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
echo "----------"