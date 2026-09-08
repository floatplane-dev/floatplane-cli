#!/bin/bash

set -e

DEPLOY_USER=bot

# which bun
# /home/$DEPLOY_USER/.bun/bin/bun

if sudo -u $DEPLOY_USER bash -lc 'which bun' 2>/dev/null | grep -Fx "/home/$DEPLOY_USER/.bun/bin/bun" >/dev/null; then
    echo "----------"
    echo "✅ Bun is already installed"
    echo "----------"
else
    echo "----------"
    echo "Installing Bun ..."
    echo "----------"
    sudo -u $DEPLOY_USER bash -lc 'curl -fsSL https://bun.sh/install | bash'

    # The install script attempts to add these 2 lines to .bashrc
    # echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.bashrc
    # echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.bashrc
    # They are responsible for add `bun` to the `$PATH`
    # However this file is not run upon login.
    # To resolve we rename this file to .bash_profile which does run on login
    sudo mv /home/$DEPLOY_USER/.bashrc /home/$DEPLOY_USER/.bash_profile

    echo "----------"
    echo "✅ Done installing Bun"
    echo "----------"
fi