#!/usr/bin/env fish

echo "----------"
echo "Removing the fish greeting ..."
set -U fish_greeting
echo "----------"
echo "Installing lambda theme for Fish ..."
omf install lambda
# TODO: omf install floatplane
echo "----------"
echo "Installing omf package for NVM ..."
omf install nvm
echo "----------"
echo "Installing NVM ..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
echo "----------"
echo "Installing the latest Node LTS version ..."
nvm install --lts
echo "----------"
echo "Setting the latest Node LTS version as default ..."
nvm use --lts
echo "----------"
echo "Installing Yarn ..."
curl -o- -L https://yarnpkg.com/install.sh | bash
echo "----------"
echo "Installing PNPM ..."
curl -fsSL https://get.pnpm.io/install.sh | sh -
source /home/admin/.config/fish/config.fish
echo "----------"
echo "Installing Deno ..."
curl -fsSL https://deno.land/x/install/install.sh | sh
fish_add_path $HOME/.deno/bin
echo "----------"
echo "Installing PM2 ..."
yarn global add pm2
echo "----------"
echo "Installing missing packages for compiling Ruby ..."
sudo apt install -y build-essential libssl-dev libreadline-dev zlib1g-dev libtool libyaml-dev
echo "----------"
echo "Installing Postgres ..."
sudo apt install -y postgresql postgresql-contrib libpq-dev
echo "----------"
echo "Installing Rbenv ..."
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
# Gotcha: normally we would use fish_add_path, but this does not work for the shims...
set -Ux fish_user_paths $HOME/.rbenv/bin $fish_user_paths
set -Ux fish_user_paths $HOME/.rbenv/shims $fish_user_paths
echo "----------"
echo "Installing Rbenv plugins ..."
mkdir ~/.rbenv/plugins
cd ~/.rbenv/plugins
git clone https://github.com/rbenv/ruby-build.git
git clone https://github.com/rbenv/rbenv-vars.git
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