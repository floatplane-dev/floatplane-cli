#!/bin/bash

set -e

domain=$1

echo "----------"
echo "Setting up Rails 🛤️ ..."
echo "----------"
echo "Changing directory ..."
cd /var/www/$domain

# LOGS

# Rails, Puma, Nginx and Bullet should log to /var/log and not log/ in Rails root.

# Create directory for logging to
sudo mkdir /var/log/$domain

# Never keeps logs older than 7 days
sudo tee /etc/logrotate.d/api.piccolo.floatplane.dev > /dev/null <<EOF
/var/log/api.piccolo.floatplane.dev/*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    copytruncate
}
EOF

# DEPLOY USER

# IMPORTANT: 
# Why bother with a deploy user? 
# Running Puma with the admin user, which has sudo powers, allows Rails to run commands as admin.
# This is considered bad practice. Instead we ought to create a "deploy" user which has only the
# few privileges needed for Puma to run the Rails app via systemd.

echo "----------"
echo "Choose short name for deploy user (e.g.: interflux, piccolo, ...):"
read deploy

echo "----------"
echo "Creating deploy user ..."

# Create a system user
sudo adduser --system --group --home /home/$deploy --shell /bin/bash $deploy

# Make the system user owner of the project root (needed for Puma)
sudo chown -R $deploy:$deploy /var/www/$domain/
sudo chown -R $deploy:$deploy /var/log/$domain/

# Use ACL to grant admin rwx permissions across project
sudo setfacl -R -m u:admin:rwx /var/www/$domain/
sudo setfacl -R -m u:admin:rwx /var/log/$domain/
sudo setfacl -R -d -m u:admin:rwx /var/www/$domain/
sudo setfacl -R -d -m u:admin:rwx /var/log/$domain/
getfacl /var/www/$domain/
getfacl /var/log/$domain/

# Prevent git from throwing a warning regarding dubious ownership
git config --global --add safe.directory /var/www/$domain

echo "✅ Done"

# RBENV

echo "----------"
echo "Installing missing packages for compiling Ruby ..."
sudo apt install -y build-essential libssl-dev libreadline-dev zlib1g-dev libtool libyaml-dev
echo "✅ Done"

echo "----------"
echo "Installing rbenv for deploy user ..."
sudo -u $deploy git clone https://github.com/rbenv/rbenv.git /home/$deploy/.rbenv
echo "✅ Done"

# We should run `rbenv init`, but fails.
# Instead we add manually what `rbenv init` would have done.
sudo -u piccolo bash -c 'echo "eval \"\$(~/.rbenv/bin/rbenv init - --no-rehash bash)\"" > /home/piccolo/.bash_profile'

# echo "----------"
# echo "Installing rbenv for admin user ..."
# git clone https://github.com/rbenv/rbenv.git ~/.rbenv
# echo '' >> ~/.config/fish/config.fish
# Make the rbenv command available to rbenv init
# echo 'fish_add_path $HOME/.rbenv/bin' >> ~/.config/fish/config.fish
# Add the shims to the PATH
# echo 'status is-interactive; and source (rbenv init - | psub)' >> ~/.config/fish/config.fish

echo "----------"
echo "Installing Rbenv plugins for deploy user ..."
sudo -u $deploy mkdir -p /home/$deploy/.rbenv/plugins
sudo -u $deploy git clone https://github.com/rbenv/ruby-build.git /home/$deploy/.rbenv/plugins/ruby-build
sudo -u $deploy git clone https://github.com/rbenv/rbenv-vars.git /home/$deploy/.rbenv/plugins/rbenv-vars
echo "✅ Done"

# echo "----------"
# echo "Installing Rbenv plugins for admin user ..."
# mkdir -p ~/.rbenv/plugins
# cd ~/.rbenv/plugins
# git clone https://github.com/rbenv/ruby-build.git
# git clone https://github.com/rbenv/rbenv-vars.git

# RUBY

echo "----------"
echo "Installing Ruby for deploy user ..."
rubyversion=$(cat .ruby-version)
echo $rubyversion
# On Mac you can simply run `rbenv install`. On Debian we must specify the exact version.
sudo -u $deploy bash -lc 'rbenv install $rubyversion --skip-existing'
echo "✅ Done"

# echo "----------"
# echo "Installing Ruby for admin user ..."
# rbenv install $rubyversion --skip-existing

# BUNDLER

# https://bundler.io/blog/2022/01/23/bundler-v2-3.html
# https://bundler.io/blog/2019/05/14/solutions-for-cant-find-gem-bundler-with-executable-bundle.html
# Until Bundler 2.3 we need to install the exact version ourselves.
# gem install bundler:2.4.6

bundlerversion=$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)
echo $bundlerversion
echo "----------"
echo "Installing Bundler for deploy user ..."
sudo -u $deploy bash -lc 'gem install bundler -v $bundlerversion'

# echo "----------"
# echo "Installing Bundler for admin user ..."
# gem install bundler -v $bundlerversion

# GEMS

echo "----------"
echo "Installing gems for deploy user ..."
sudo -u $deploy bash -lc 'bundle install'
echo "✅ Done"

# echo "----------"
# echo "Installing gems for admin user ..."
# bundle install

# SECRETS

echo "----------"
echo "Enter the config/credentials/production.key:"
read -s production_key
echo $production_key >> config/credentials/production.key
echo "✅ Done"

# ENVIRONMENT

# The .rbenv-vars below makes all other commands run in production mode.
# No more need to prepend `RAILS_ENV=production` to all commands.
# No more need to append `-e production` to `rails` commands`
# Simply run:
# * bin/rails c
# * bin/rails db:migrate
# * bin/puma -C config/puma.rb

echo "----------"
echo "Setting RAILS_ENV=production on rbenv-vars"
echo "RAILS_ENV=production" >> .rbenv-vars
echo "✅ Done"

# POSTGRES

echo "----------"
echo "Installing Postgres ..."
sudo apt install -y postgresql postgresql-contrib libpq-dev
echo "✅ Done"

# POSTGRES USER

echo "----------"
echo "Installing Postgres user ..."
if sudo -u postgres psql -t -c '\du' | cut -d \| -f 1 | grep -qw $deploy; then
  echo "----------"
  echo "Skipping Postgres user setup"
else
  echo "----------"
  echo "Creating Postgres user named \"$deploy\" ..."
  sudo -u postgres createuser -s $deploy
  echo "----------"
  echo "Enter Postgres user password:"
  echo "👉🏼 Store this in 1Password"
  echo "👉🏼 Store this in config/credentials/production.yml.enc"
  read -s db_pass
  sudo -u postgres psql -c "ALTER USER $deploy WITH PASSWORD '$db_pass';"
fi
echo "✅ Done"

# CREATE DATABASE

echo "----------"
echo "Creating database ..."
sudo -u $deploy bash -lc 'bin/rails db:create'
echo "✅ Done"

# DATABASE SCHEMA

echo "----------"
echo "Apply database schema..."
sudo -u $deploy bash -lc 'bin/rails db:schema:load'
echo "✅ Done"

# PUMA

echo "----------"
echo "Configuring Puma service"
sudo ln -s /var/www/$domain/config/puma.service /etc/systemd/system/$deploy.service
sudo systemctl daemon-reload
echo "✅ Done"

echo "----------"
echo "Starting Puma service"
sudo service $deploy start
echo "✅ Done"