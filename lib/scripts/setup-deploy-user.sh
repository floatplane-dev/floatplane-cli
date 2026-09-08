#!/bin/bash

set -e

DEPLOY_USER=bot

# Important: 
# Never run a service (Rails, Svelte Kit, Deno, ...) on your server with the sudo user.
# This poses a security risk because the service will have elevated permissions server access.
# Always create a "deploy user" who has the bare minimum permissions to run the service.

if id -u $DEPLOY_USER >/dev/null 2>&1; then
    echo "----------"
    echo "✅ Deploy user \"$DEPLOY_USER\" already exists"
    echo "----------"
else
    echo "----------"
    echo "Creating deploy user named: $DEPLOY_USER"
    echo "----------"
    sudo adduser --system --group --home /home/$DEPLOY_USER --shell /bin/bash $DEPLOY_USER
    echo "----------"
    echo "✅ Created deploy user"
    echo "----------"
fi