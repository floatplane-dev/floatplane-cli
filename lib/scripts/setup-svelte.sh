#!/bin/bash

set -e

domain=$1
deploy=$2
server=$3

wait_until_yes() {
  while true; do
  select answer in yes no; do
      case $answer in
      yes) break 2;;
      no)  echo "Please do so now";;
      *)   echo "Invalid choice";;
      esac
  done
  done
}

echo "----------"
echo "Setting up Svelte Kit ⚡️"
echo "----------"
echo "cd /var/www/$domain"
cd /var/www/$domain
echo "----------"

# Outdated
# grep -qE "from\s*['\"]@sveltejs/adapter-node['\"]" svelte.config.* || {
#     echo "❌ adapter-node is not the default adaptor" >&2
#     exit 1
# }

if [[ ! -f /var/www/"$domain"/systemd.service ]]; then
    echo "❌ systemd.service does not exist" >&2
    exit 1
fi

if [ -f ".env.example" ] && [ ! -f ".env.production" ]; then
  echo "----------"

  cp .env.example .env.production

  echo "✅ Template for secrets prepared"
  echo "----------"
  echo "Next steps"
  echo " ↳ ssh $server"
  echo " ↳ cd /var/www/$domain"
  echo " ↳ vim .env.production"
  echo " ↳ add secrets"
  echo " ↳ save"
  echo ""
  echo "Done?"
  
  wait_until_yes
  
  echo "----------"
  echo "✅ Secrets added"
  echo "----------"

  sudo chown $deploy:$deploy .env.production

  echo "✅ Permissions set on secrets"
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
sudo ln -nsf /var/www/$domain/systemd.service /etc/systemd/system/$domain.service
sudo systemctl daemon-reload
echo "✅ Done"
echo "----------"
echo "Starting daemon"
sudo systemctl stop $domain
sudo systemctl start $domain
sudo systemctl status $domain --no-pager
echo "✅ Done"
echo "----------"