#/bin/bash

set -e

echo "----------"
echo "Installing git, curl, nginx, certbot and ufw fish ..."
sudo apt update
sudo apt -y install git curl nginx certbot python3-certbot-nginx ufw fish jq acl
echo "✅ done"
echo "----------"
echo "Setting Fish as default shell 🐟 ..."
chsh -s /usr/bin/fish
echo "✅ done"