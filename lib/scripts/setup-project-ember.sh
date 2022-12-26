#!/bin/bash

set -e
set -o pipefail

domain=$1
repo=$2
redirect_www=$3

echo "Setting up Ember project 🐹 ..."
echo "domain=$domain"
echo "repo=$repo"
echo "----------"
echo "Removing existing setup ..."
rm -rf ~/.ssh/bot@$domain
rm -rf /var/www/$domain
rm -rf /etc/nginx/sites-enabled/$domain.conf
echo "----------"
echo "Generating new SSH key ..."
ssh-keygen -t rsa -b 4096 -C "readonly@$domain" -f ~/.ssh/readonly@$domain -P ""
cat ~/.ssh/readonly@$domain.pub
echo "----------"
echo "ACTION REQUIRED:"
echo "1. Please copy the public key above."
echo "2. Open Github and go to the repository of $domain."
echo "3. Add public key as read-only deploy key."
echo "4. Done? y/n"

while :
do
read -s -n 1 input
case $input in
  y)
    echo "Done!"
    break;
    ;;
  n)
    echo "Quit"
    exit 0;
    ;;
esac
done

echo "----------"
echo "Cloning repo ..."
(
  set -x
  GIT_SSH_COMMAND="ssh -i ~/.ssh/readonly@$domain" git clone $repo /var/www/$domain
)
echo "----------"
echo "Enter repo directory ..."
echo "cd /var/www/$domain"
cd /var/www/$domain
echo "----------"
echo "Configuring Git SSH to use the readonly SSH key ..."
(
  set -x
  git config core.sshCommand "ssh -i ~/.ssh/readonly@$domain -F /dev/null"
)
echo "----------"
echo "Pulling latest production code ..."
(
  set -x
  git checkout production
  git pull
)

# NVM

if [ -f ".nvmrc" ]; then
  echo "----------"
  echo "Installing Node with NVM ..."

  # This hack makes the nvm binary available to this script.
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

  nvm install
fi

# NODE MODULES

if [ -f "package.json" ]; then
  echo "Found package.json"
  if [ -f ".npmrc" ]; then
    echo "----------"
    echo "Found .npmrc"
    echo "Installing Node packages with PNPM ..."
    ( set -x; pnpm install )

    echo "----------"
    echo "Building dist ..."
    ( set -x; pnpm build )
  fi

  if [ -f "yarn.lock" ]; then
    echo "----------"
    echo "Found yarn.lock"
    echo "Installing Node packages with Yarn ..."
    ( set -x; yarn install )

    echo "----------"
    echo "Building dist ..."
    ( set -x; yarn build )
  fi
fi

# PM2

if [ -f "ecosystem.config.js" ]; then
  echo "----------"
  echo "Starting PM2 daemon ..."
  ( set -x; pm2 start )
fi

# EMBER FASTBOOT

if [ -f "fastboot.js" ]; then
  echo "----------"
  echo "Spinning up Fastboot ..."
  ( set -x; pm2 start fastboot.js )
fi

echo "----------"
echo "Configuring Nginx for HTTP..."
( set -x; sudo ln -nsf /var/www/$domain/nginx/$domain.temp.conf /etc/nginx/sites-enabled/$domain.conf )

echo "----------"
echo "Testing Nginx configs..."
( set -x; sudo nginx -t )

echo "----------"
echo "Restarting Nginx..."
( set -x; sudo systemctl restart nginx )

echo "----------"
echo "Creating SSL certificates..."
(
  set -x
  sudo certbot certonly --nginx -d $domain
  if [ "$redirect_www" = true ] ; then
    echo "Creating extra certificate for redirecting www"
    sudo certbot certonly --nginx -d www.$domain
  fi
)

echo "----------"
echo "Configuring Nginx for HTTPS..."
( set -x; sudo ln -nsf /var/www/$domain/nginx/$domain.conf /etc/nginx/sites-enabled/$domain.conf )

echo "----------"
echo "Testing Nginx configs... (again)"
( set -x; sudo nginx -t )

echo "----------"
echo "Restarting Nginx... (again)"
( set -x; sudo systemctl restart nginx )

echo "----------"
echo "Done!"
echo "----------"
echo "NEXT STEPS"
echo "👉🏼 Open $domain in your browser. Are we live?!"
echo "👉🏼 Manually add environment secrets such as .env files, then rebuild."
echo "👉🏼 Set up automated deploy pipeline for production (CD)"
echo "----------"
