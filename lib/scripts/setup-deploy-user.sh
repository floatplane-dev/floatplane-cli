#!/bin/bash

set -e

deploy=$1

# Important: 
# Never run a service (Rails, Svelte Kit, Deno, ...) on your server with the sudo user.
# This poses a security risk because the service will have elevated permissions server access.
# Always create a "deploy user" who has the bare minimum permissions to run the service.

if id -u $deploy >/dev/null 2>&1; then
    echo "----------"
    echo "✅ Deploy user \"$deploy\" already exists"
    echo "----------"
else
    echo "----------"
    echo "Creating deploy user named: $deploy"
    echo "----------"
    sudo adduser --system --group --home /home/$deploy --shell /bin/bash $deploy
    echo "----------"
    echo "✅ Created deploy user"
    echo "----------"
fi