#!/usr/bin/env fish

set SUDO_USER admin

echo "----------"
echo "Removing the fish greeting ..."
set -U fish_greeting
echo "✅ done"
echo "----------"
echo "Installing lambda theme for Fish ..."
omf install lambda
echo "✅ done"
echo "----------"
echo "Create domain root directory"
sudo mkdir -p /var/www/
sudo chown -R $SUDO_USER:$SUDO_USER /var/www/
ls -la /var/www/
echo "✅ done"
echo "----------"
echo "Change owner of nginx directories"
sudo chown -R $SUDO_USER:$SUDO_USER /etc/nginx/sites-enabled/
sudo chown -R $SUDO_USER:$SUDO_USER /etc/nginx/sites-available/
chmod -R g+s /etc/nginx/sites-enabled/
chmod -R g+s /etc/nginx/sites-available/
echo "✅ done"
echo "----------"
echo "Unlink the default Nginx page"
sudo unlink /etc/nginx/sites-enabled/default
echo "✅ done"
echo "----------"
echo "Test the nginx configs"
sudo nginx -t
echo "✅ done"
echo "----------"
echo "Start nginx"
sudo systemctl start nginx
echo "✅ done"
echo "----------"
echo "Sanity check nginx status"
sudo systemctl status nginx --no-pager
echo "✅ done"
echo "----------"
echo "Hush the welcome message"
sudo touch ~/.hushlogin
echo "✅ done"
echo "----------"
echo "Configure certbot"
echo "👉🏼 enter email"
echo "👉🏼 agree to terms"
echo "👉🏼 no spam please"
echo "👉🏼 cancel"
sudo certbot register
echo "✅ done"
echo "----------"
echo "Configure git"
git config --global pull.rebase false
echo "✅ done"
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
echo "✅ done"
echo "----------"
echo "Rebooting server for the new firewall to take effect"
echo "sudo reboot"

sudo reboot

echo "✅ done"