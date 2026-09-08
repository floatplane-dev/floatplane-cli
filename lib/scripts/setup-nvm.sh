#!/bin/bash

set -e

DEPLOY_USER=bot

if sudo test -f "/home/$DEPLOY_USER/.bash_profile"; then
    echo "----------"
    echo "✅ .bash_profile already exists"
    echo "----------"
else
    echo "----------"
    echo "Creating .bash_profile ..."
    echo "----------"
    sudo -u $DEPLOY_USER bash -lc "touch ~/.bash_profile"
    echo "----------"
    echo "✅ Created .bash_profile"
    echo "----------"
fi

# Note: `which nvm` returns nothing because NVM is not an executable binary.
# It's a shell function defined in ~/.nvm/nvm.sh.

if sudo -u interflux bash -lc 'command -v nvm' | grep -Fxq "nvm"; then
    echo "----------"
    echo "✅ NVM is already installed"
    echo "----------"
else
    echo "----------"
    echo "Installing NVM ..."
    echo "----------"
    sudo -u $DEPLOY_USER bash -lc 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash'
    echo "----------"
    echo "✅ Done installing NVM"
    echo "----------"
fi