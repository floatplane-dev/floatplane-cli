#/bin/sh

set -e
set -o pipefail

echo "----------"
echo "Great, we're on the server."
echo "----------"
echo "Password for new admin user?"
read -s pass_admin
echo "----------"
echo "Creating admin user ..."
useradd --password $pass_admin --create-home --groups sudo admin
# echo "----------"
# echo "Creating SSH directory ..."
# mkdir /home/admin/.ssh
# echo "----------"
# echo "Moving authorized keys from root to admin ..."
# mv /root/.ssh/authorized_keys /home/admin/.ssh/
# chown -R admin:admin /home/admin/.ssh
echo "----------"
echo "Silencing the login message ..."
touch /home/admin/.hushlogin
echo "----------"
exit 0;

# echo "Authorizing the public SSH key admin@$domain"
# echo "$public_ssh_key" > "/home/admin/.ssh/authorized_keys"


# Create the admins user.
# Add him to the sudo group.
# Do not add a password, we'll use SSH.

useradd --password $pass_admin --create-home --groups sudo admin

# Create a user for the deploy bot.
# Do not add to sudo, nor use password.

useradd --password $pass_bot --create-home bot

# Create SSH directories.

mkdir /home/admin/.ssh
mkdir /home/bot/.ssh

# Ask for public SSH keys.

# locally
# ssh-keygen -t rsa -b 4096 -C "jw" -f ~/.ssh/jw
# store the passwwords securely
# ssh-keygen -t rsa -b 4096 -C "bot" -f ~/.ssh/bot -P ""
# no password on the bot's key
# cat ~/.ssh/jw.pub
# cat ~/.ssh/bot.pub

echo "Public SSH key of jw?"
read temp3
echo "Public SSH key of bot?"
read temp4

# Authorise these keys.

echo "$temp3" > "/home/jw/.ssh/authorized_keys"
echo "$temp4" > "/home/bot/.ssh/authorized_keys"

# Silence the login messages.

touch /home/jw/.hushlogin
touch /home/bot/.hushlogin

# From this point onwards you should be able to do:
# ssh -i ~/.ssh/jw jw@1.1.1.1
# ssh -i ~/.ssh/bot bot@1.1.1.1

# TODO: ask if works

# ----------

# LOCK DOWN THE ROOT USER

sudo vim /etc/ssh/sshd_config
# PasswordAuthentication no
# PermitRootLogin no
# Save
sudo service ssh restart

# If AWS server, remove admin user
deluser admin

# ----------

# INSTALL GIT, CURL, NGINX, CERTBOT, UFW, FISH

# Make Fish known to apt
echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_10/ /' | sudo tee /etc/apt/sources.list.d/shells:fish:release:3.list
curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_10/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg > /dev/null

# Update package information
sudo apt update

# Install all packages!
sudo apt --assume-yes install git curl nginx certbot python-certbot-nginx ufw fish

# ----------

# CONFIGURE FISH

# Set fish as default shell
chsh -s /usr/bin/fish

# Switch from bash to fish
fish

# Install Oh My Fish
curl -L https://get.oh-my.fish | fish

# Install theme (optional)
omf install bira
omf install lambda

# Remove the welcome message
set fish_greeting

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

# RUBY, RBENV, POSTGRES

# Install missing packages for compiling Ruby
sudo apt install -y build-essential libssl-dev libreadline-dev zlib1g-dev

# Install all packages for Postgres
sudo apt install -y postgresql postgresql-contrib libpq-dev

# Install Rbenv for managing Ruby versions
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
set -Ux fish_user_paths $HOME/.rbenv/bin $fish_user_paths
set -Ux fish_user_paths $HOME/.rbenv/shims $fish_user_paths
rbenv -v

# Install the rbenv plugins `ruby-build` and `rbenv-vars`:
mkdir ~/.rbenv/plugins
cd ~/.rbenv/plugins
git clone https://github.com/rbenv/ruby-build.git
git clone https://github.com/rbenv/rbenv-vars.git

# Set a default Ruby version at user root
echo "2.6.5" >> ~/.ruby-version
rbenv install
ls -la /home/jw/.rbenv/versions/
du -sh /home/jw/.rbenv/versions/*
ruby  -v
gem -v

# ----------

# CONFIGURE NGINX

# Own the Nginx directories
sudo chown -R jw:jw /etc/nginx/sites-enabled/
chmod -R g+s /etc/nginx/sites-enabled/

# Test if the current config passes
sudo nginx -t

# Start Nginx
sudo systemctl start nginx

# ----------

# CONFIGURE CERTBOT

sudo certbot
# Enter email
# Agree to terms
# No spam please
# Cancel

# ----------

# CONFIGURE FIREWALL

sudo ufw status verbose
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 'Nginx HTTP'
sudo ufw allow 'Nginx HTTPS'
sudo ufw enable
sudo ufw status verbose
# Needs reboot to take effect, which will do in the next steps.

# ----------

# CONFIGURE HOST

# Hush the welcome message
touch ~/.hushlogin

# Optionally improve the server's name (don't use dots in the name!)
sudo vim /etc/hostname

# Then also update the end of 127.0.0.1 to the same name
sudo vim /etc/hosts

# ----------

# REBOOT AND TEST

sudo reboot
# Wait 10 sec
ssh root@1.2.3.4
# Should fail
ssh jw@1.2.3.4
# Should work
# Should show new server name
# Should use fish as shell
# Should not show fish welcome message
# Should not show host welcome stats

# ----------

# CREATE THE DEPLOY GROUP AND BOT

# Create bot user
sudo adduser bot

# Create deploy group
sudo groupadd deploy

# Add yourself and bot to deploy group
sudo usermod -a -G deploy jw
sudo usermod -a -G deploy bot

# On your local create an SSH key to connect to the remote
ssh-keygen -t rsa -b 4096 -C "bot@server.interflux.com" -f ~/.ssh/bot@server.interflux.com -P ""

# Copy the public key
cat ~/.ssh/bot@server.interflux.com.pub

# Then log in as bot user and add the public SSH key as trusted key for later login
su - bot
mkdir ~/.ssh
vim ~/.ssh/authorized_keys
# Paste key

# Silence the login
touch ~/.hushlogin

# Scroll up and install
# Fish
# NVM
# Node
# Yarn

# Exit remote, from your local test bot login
exit
ssh bot@server.interflux.com -i ~/.ssh/bot@server.interflux.com
su - jw

# ----------

# CREATE PROJECT DIRECTORY

# Create folder for projects (www) and the git repos (repo).
sudo mkdir /var/www/
# Make jw the owner of /var/www/ and access to deploy group
sudo chown -R jw:deploy /var/www/
# Give the deploy group read and write access
sudo chmod -R g+w /var/www/
# Make sure these permissions are inherited when future files and folders are created within.
sudo chmod -R g+s /var/www/
# Verify your user is the owner of `./` and you have `drwxr-sr-x` permissions (not `drwxr-xr-x`)
ls -la /var/www/
