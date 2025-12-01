#!/bin/bash

set -e

domain=$1
deploy=$2

echo "----------"
echo "Setting up Rails 🛤️ ..."
echo "----------"
echo "Changing directory ..."
cd /var/www/$domain
echo "✅ Done"

# POSTGRES

echo "----------"
echo "Installing Postgres ..."
sudo apt install -y postgresql postgresql-contrib libpq-dev
echo "✅ Done"

# POSTGRES USER

echo "----------"
echo "Creating Postgres user named \"$deploy\" ..."
sudo -u postgres createuser -s $deploy
echo "✅ Done"
echo "----------"
echo "Enter Postgres user password:"
echo "👉🏼 Store this in 1Password"
echo "👉🏼 Store this in config/credentials/production.yml.enc"
read -s db_pass
sudo -u postgres psql -c "ALTER USER $deploy WITH PASSWORD '$db_pass';"
echo "✅ Done"

# RBENV

echo "----------"
echo "Installing missing packages for compiling Ruby ..."
sudo apt install -y build-essential libssl-dev libreadline-dev zlib1g-dev libtool libyaml-dev
echo "✅ Done"

echo "----------"
echo "Installing rbenv for deploy user ..."
sudo -u $deploy git clone https://github.com/rbenv/rbenv.git /home/$deploy/.rbenv
# We should run `rbenv init`, but fails.
# Instead we add manually what `rbenv init` would have done.
sudo -u piccolo bash -c 'echo "eval \"\$(~/.rbenv/bin/rbenv init - --no-rehash bash)\"" > /home/piccolo/.bash_profile'
echo "✅ Done"

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
sudo -u $deploy bash -lc "rbenv install $rubyversion --skip-existing"
echo "✅ Done"

# echo "----------"
# echo "Installing Ruby for admin user ..."
# rbenv install $rubyversion --skip-existing

# BUNDLER

# https://bundler.io/blog/2022/01/23/bundler-v2-3.html
# https://bundler.io/blog/2019/05/14/solutions-for-cant-find-gem-bundler-with-executable-bundle.html
# Until Bundler 2.3 we need to install the exact version ourselves.

echo "----------"
echo "Installing Bundler v$bundlerversion for deploy user ..."
sudo -u $deploy bash -lc "gem install bundler -v \"$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)\""
echo "✅ Done"

# echo "----------"
# echo "Installing Bundler for admin user ..."
# gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)"

# GEMS

echo "----------"
echo "Installing gems for deploy user ..."
sudo -u $deploy bash -lc "bundle install"
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

# CREATE DATABASE

echo "----------"
echo "Creating database ..."
sudo -u $deploy bash -lc "bin/rails db:create"
echo "✅ Done"

# DATABASE SCHEMA

echo "----------"
echo "Apply database schema..."
sudo -u $deploy bash -lc "bin/rails db:schema:load"
echo "✅ Done"

# PUMA

echo "----------"
echo "Configuring Puma service"
sudo ln -s /var/www/$domain/config/puma.service /etc/systemd/system/$deploy.service
sudo systemctl daemon-reload
echo "✅ Done"

echo "----------"
echo "Starting Puma service"
sudo systemctl start $deploy
sudo systemctl status $deploy --no-pager
echo "✅ Done"