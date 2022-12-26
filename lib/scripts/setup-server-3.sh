#/bin/bash

set -e

echo "----------"
echo "Installing git, curl, nginx, certbot and ufw fish ..."
echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_11/ /' | sudo tee /etc/apt/sources.list.d/shells:fish:release:3.list
curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_11/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg > /dev/null
sudo apt update
sudo apt -y install git curl nginx certbot python3-certbot-nginx ufw fish
echo "----------"
echo "Setting Fish as default shell 🐟 ..."
chsh -s /usr/bin/fish
echo "----------"
exit 0;