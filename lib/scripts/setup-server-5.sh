#!/usr/bin/env fish

echo "----------"
echo "Removing the fish greeting ..."
set -U fish_greeting
echo "----------"
echo "Installing lambda theme for Fish ..."
omf install lambda
echo "----------"
echo "Create directories for projects"
sudo mkdir -p /var/www/
sudo chown -R admin:admin /var/www/
ls -la /var/www/
echo "----------"
echo "Change owner of nginx directories"
sudo chown -R admin:admin /etc/nginx/sites-enabled/
sudo chown -R admin:admin /etc/nginx/sites-available/
chmod -R g+s /etc/nginx/sites-enabled/
chmod -R g+s /etc/nginx/sites-available/
echo "----------"
echo "Unlink the default Nginx page"
sudo unlink /etc/nginx/sites-enabled/default
echo "----------"
echo "Test the nginx configs"
sudo nginx -t
echo "----------"
echo "Start nginx"
sudo systemctl start nginx
echo "----------"
echo "Sanity check nginx status"
sudo systemctl status nginx --no-pager
echo "----------"
echo "Hush the welcome message"
sudo touch ~/.hushlogin
echo "----------"
echo "Configure certbot"
echo "👉🏼 enter email"
echo "👉🏼 agree to terms"
echo "👉🏼 no spam please"
echo "👉🏼 cancel"
sudo certbot register
echo "----------"
echo "Configure git"
git config --global pull.rebase false
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