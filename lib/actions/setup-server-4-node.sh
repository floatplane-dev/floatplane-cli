#/bin/sh

set -e
set -o pipefail

# ----------

# INSTALL NVM, NODE, YARN, PM2

# Install NVM for letting each project install and use their own version of Node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
omf install nvm
nvm list
# Copy newest LTS version

# Install the latest version of Node as default
nvm install v12.18.3
node -v

# Install Yarn for installing Node package in repos
curl -o- -L https://yarnpkg.com/install.sh | bash
# set -U fish_user_paths (yarn global bin) $fish_user_paths
bash
fish
yarn -v

# Install pm2 for running and monitoring Node scripts
yarn global add pm2

# ----------

exit 0;