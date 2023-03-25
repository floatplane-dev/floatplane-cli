#!/bin/bash

set -e

domain=$1

echo "----------"
echo "Setting up Ember 🐹"
echo "----------"
echo "Changing directory ..."
cd /var/www/$domain

# SET UP SECRETS

if [ -f ".env.example" ]; then
  echo "----------"
  echo "Enter the production environment variables for .env file."
  echo "Use the following format:"
  cat .env.example
  read -s env_vars
  echo $env_vars >> .env
fi

# NVM

if [ -f .nvmrc ]; then
  echo "----------"
  echo "Installing Node with NVM ..."

  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

  nvm install
fi

# NODE MODULES

if [ -f package.json ]; then
  echo "Found package.json"
  if [ -f .npmrc ]; then
    echo "----------"
    echo "Found .npmrc"
    echo "Installing Node packages with PNPM ..."
    pnpm install

    echo "----------"
    echo "Building dist ..."
    pnpm build
  fi

  if [ -f yarn.lock ]; then
    echo "----------"
    echo "Found yarn.lock"
    echo "Installing Node packages with Yarn ..."
    yarn install

    echo "----------"
    echo "Building dist ..."
    yarn build
  fi
fi

# PM2

if [ -f "ecosystem.config.js" ]; then
  echo "----------"
  echo "Starting PM2 daemon ..."
  pm2 start
fi

# EMBER FASTBOOT

if [ -f "fastboot.js" ]; then
  echo "----------"
  echo "Spinning up Fastboot ..."
  pm2 start fastboot.js
fi
