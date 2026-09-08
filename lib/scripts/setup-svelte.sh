#!/bin/bash

set -e

DOMAIN=$1
SSH_HOST=$2
DEPLOY_USER=bot

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
echo "cd /var/www/$DOMAIN"
cd /var/www/$DOMAIN
echo "----------"

# Outdated
# grep -qE "from\s*['\"]@sveltejs/adapter-node['\"]" svelte.config.* || {
#     echo "❌ adapter-node is not the default adaptor" >&2
#     exit 1
# }

if [[ ! -f /var/www/"$DOMAIN"/systemd.service ]]; then
    echo "❌ systemd.service does not exist" >&2
    exit 1
fi

if [ -f ".env.example" ] && [ ! -f ".env.production" ]; then
  echo "----------"

  cp .env.example .env.production

  echo "✅ Template for secrets prepared"
  echo "----------"
  echo "Next steps"
  echo " ↳ ssh $SSH_HOST"
  echo " ↳ cd /var/www/$DOMAIN"
  echo " ↳ vim .env.production"
  echo " ↳ add secrets"
  echo " ↳ save"
  echo ""
  echo "Done?"
  
  wait_until_yes
  
  echo "----------"
  echo "✅ Secrets added"
  echo "----------"

  sudo chown $DEPLOY_USER:$DEPLOY_USER .env.production

  echo "✅ Permissions set on secrets"
  echo "----------"
else
  echo "----------"
  echo "✅ .env.production already exists"
  echo "----------"
fi

# BUILD

echo "git pull"
sudo -u $DEPLOY_USER bash -lc "cd /var/www/$DOMAIN; git pull"
echo "✅ Done"
echo "----------"
echo "nvm install"
sudo -u $DEPLOY_USER bash -lc "cd /var/www/$DOMAIN; nvm install"
echo "✅ Done"
echo "----------"
echo "npm install"
sudo -u $DEPLOY_USER bash -lc "cd /var/www/$DOMAIN; npm install"
echo "✅ Done"
echo "----------"
echo "npm run build"
sudo -u $DEPLOY_USER bash -lc "cd /var/www/$DOMAIN; npm run build"
echo "✅ Done"
echo "----------"

# DAEMON

echo "Configuring daemon"
sudo ln -nsf /var/www/$DOMAIN/systemd.service /etc/systemd/system/$DOMAIN.service
sudo systemctl daemon-reload
echo "✅ Done"
echo "----------"
echo "Starting daemon"
sudo systemctl stop $DOMAIN
sudo systemctl start $DOMAIN
sudo systemctl status $DOMAIN --no-pager
echo "✅ Done"
echo "----------"