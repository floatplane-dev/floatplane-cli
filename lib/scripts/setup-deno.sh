#!/bin/bash

set -e

DOMAIN=$1

echo "----------"
echo "Setting up Deno 🦕"
echo "----------"
echo "Changing directory ..."
cd /var/www/$DOMAIN
echo "----------"
echo "Installing Deno ..."
curl -fsSL https://deno.land/x/install/install.sh | sh
fish_add_path $HOME/.deno/bin
echo "----------"
echo "Installing PM2 ..."
yarn global add pm2

# SET UP SECRETS

if [ -f ".env.example" ]; then
  echo "----------"
  echo "Enter the production environment variables for .env file."
  echo "Use the following format:"
  cat .env.example
  read -s env_vars
  echo $env_vars >> .env
fi

# PM2

if [ -f "ecosystem.config.js" ]; then
  echo "----------"
  echo "Starting PM2 daemon ..."
  pm2 start
fi
