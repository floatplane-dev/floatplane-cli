#!/bin/bash

set -e

deploy=$1

if [ -f ~/.bash_profile ]; then
    echo "~/.bash_profile already exists"
    ls -l ~/.bash_profile
else
    echo "----------"
    echo "Creating .bash_profile ..."
    touch ~/.bash_profile
    echo "----------"
    echo "✅ Created .bash_profile"
    echo "----------"
fi

# Note: `which nvm` returns nothing because NVM is not an executable binary.
# It's a shell function defined in ~/.nvm/nvm.sh.


if sudo -u $deploy bash -lc 'which pm2' 2>/dev/null | grep -Fx "/home/$deploy/.bun/bin/pm2" >/dev/null; then

if sudo -u interflux bash -lc 'command -v nvm' | grep -Fxq "nvm"; then
    echo "----------"
    echo "✅ NVM is already installed"
    echo "----------"
else
    echo "----------"
    echo "Installing NVM ..."
    echo "----------"
    sudo -u $deploy bash -lc 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash'
    echo "----------"
    echo "✅ Done installing NVM"
    echo "----------"
fi