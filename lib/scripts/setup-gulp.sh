#!/bin/bash

set -e

domain=$1

echo "----------"
echo "Setting up Gulp 🍹"
echo "----------"
echo "Changing directory ..."
cd /var/www/$domain

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