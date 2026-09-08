#!/bin/bash

# DEPRECATED

set -e

DOMAIN=$1

echo "----------"
echo "Setting up Gulp 🍹"
echo "----------"
echo "Changing directory ..."
cd /var/www/$DOMAIN

# TODO: REVIEW
# echo "----------"
# echo "Installing omf package for NVM ..."
# omf install nvm
# echo "----------"
# echo "Installing NVM ..."
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
# echo "----------"
# echo "Installing the latest Node LTS version ..."
# nvm install --lts
# echo "----------"
# echo "Setting the latest Node LTS version as default ..."
# nvm use --lts
# echo "----------"
# echo "Installing Yarn ..."
# curl -o- -L https://yarnpkg.com/install.sh | bash
# echo "----------"
# echo "Installing PNPM ..."
# curl -fsSL https://get.pnpm.io/install.sh | sh -
# source /home/admin/.config/fish/config.fish

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