#!/bin/bash

set -e

DEPLOY_USER=bot

# which pm2
# /home/$DEPLOY_USER/.bun/bin/pm2

if sudo -u $DEPLOY_USER bash -lc 'which pm2' 2>/dev/null | grep -Fx "/home/$DEPLOY_USER/.bun/bin/pm2" >/dev/null; then
    echo "----------"
    echo "✅ PM2 is already installed"
    echo "----------"
else
    echo "----------"
    echo "Installing PM2 ..."
    echo "----------"
    sudo -u $DEPLOY_USER bash -lc 'bun install -g pm2'
    echo "----------"
    echo "Run PM2 upon startup"

    echo "🚧 TODO 🚧"
    echo "🚧 TODO 🚧"
    echo "🚧 TODO 🚧"

    # pm2 startup

    # TODO: find automated way
    # TODO: figure out how to run PM2 as deploy user

    # [PM2] Init System found: systemd
    # [PM2] To setup the Startup Script, copy/paste the following command:
    # sudo env PATH=$PATH:/home/admin/.nvm/versions/node/v14.17.0/bin /home/admin/.bun/install/global/node_modules/pm2/bin/pm2 startup systemd -u admin --hp /home/admin

    echo "----------"
    echo "✅ Done installing PM2"
    echo "----------"
fi