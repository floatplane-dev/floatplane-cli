#/bin/bash

set -e

echo "----------"
echo "Installing git, curl, nginx, certbot and ufw fish ..."
echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_11/ /' | sudo tee /etc/apt/sources.list.d/shells:fish:release:3.list
curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_11/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg > /dev/null
sudo apt update
sudo apt -y install git curl nginx certbot python3-certbot-nginx ufw fish
echo "----------"
echo "Create directories for projects"
sudo mkdir -p /var/www/
sudo chown -R admin:admin /var/www/
ls -la /var/www/
echo "----------"
echo "Change owner of nginx directories"
sudo chown -R admin:admin /etc/nginx/sites-enabled/
chmod -R g+s /etc/nginx/sites-enabled/
echo "----------"
echo "Test the nginx configs"
sudo nginx -t
echo "----------"
echo "Start nginx"
sudo systemctl start nginx
echo "----------"
echo "Sanity check nginx status"
sudo systemctl status nginx
echo "----------"
echo "Hush the welcome message"
sudo touch ~/.hushlogin
echo "----------"
echo "Configure certbot"
echo "👉🏼 enter email"
echo "👉🏼 agree to terms"
echo "👉🏼 no spam please"
echo "👉🏼 cancel"
if sudo certbot register; then
  echo "done"
fi
# TODO: find a way to automate
# echo "----------"
# echo "Installing oh my fish"
# fish -c 'curl -L https://get.oh-my.fish | fish'
# curl -L https://get.oh-my.fish | fish -c 'fish'
# echo "----------"
# echo "Installing lambda theme for fish"
# fish -c 'omf install lambda'
echo "----------"
echo "Removing the fish greeting ..."
fish -c 'set -U fish_greeting ""'
echo "----------"
echo "Setting Fish as default shell ..."
chsh -s /usr/bin/fish
echo "----------"
echo "Configuring firewall ..."
sudo ufw status verbose
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 'Nginx HTTP'
sudo ufw allow 'Nginx HTTPS'
sudo ufw enable
sudo ufw status verbose
echo "----------"
echo "Rebooting server for the new firewall to take effect"
echo sudo reboot