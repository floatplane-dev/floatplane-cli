#!/bin/bash

set -e

domain=$1

echo "----------"
echo "Setting up Deno 🦕"
echo "----------"
echo "Changing directory ..."
cd /var/www/$domain

# PM2

if [ -f "ecosystem.config.js" ]; then
  echo "----------"
  echo "Starting PM2 daemon ..."
  pm2 start
fi
