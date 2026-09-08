#!/bin/bash

set -e

DOMAIN=$1
DEPLOY_USER=bot

echo "----------"
echo "Setting up Rails 🛤️ ..."
echo "----------"
echo "Changing directory ..."
cd /var/www/$DOMAIN
echo "✅ Done"

# POSTGRES

echo "----------"
echo "Installing Postgres ..."
sudo apt install -y postgresql postgresql-contrib libpq-dev
echo "✅ Done"

# POSTGRES USER

echo "----------"
echo "Creating Postgres user named \"$DEPLOY_USER\" ..."
sudo -u postgres createuser -s $DEPLOY_USER
echo "✅ Done"
echo "----------"
echo "Enter Postgres user password:"
echo "👉🏼 Store this in 1Password"
echo "👉🏼 Store this in config/credentials/production.yml.enc"
read -s DB_PASS
sudo -u postgres psql -c "ALTER USER $DEPLOY_USER WITH PASSWORD '$DB_PASS';"
echo "✅ Done"

# RBENV

echo "----------"
echo "Installing missing packages for compiling Ruby ..."
sudo apt install -y build-essential libssl-dev libreadline-dev zlib1g-dev libtool libyaml-dev
echo "✅ Done"

echo "----------"
echo "Installing rbenv for deploy user ..."
sudo -u $DEPLOY_USER git clone https://github.com/rbenv/rbenv.git /home/$DEPLOY_USER/.rbenv
# We should run `rbenv init`, but fails.
# Instead we add manually what `rbenv init` would have done.
sudo -u $DEPLOY_USER bash -c 'echo "eval \"\$(~/.rbenv/bin/rbenv init - --no-rehash bash)\"" > /home/$DEPLOY_USER/.bash_profile'
echo "✅ Done"

echo "----------"
echo "Installing Rbenv plugins for deploy user ..."
sudo -u $DEPLOY_USER mkdir -p /home/$DEPLOY_USER/.rbenv/plugins
sudo -u $DEPLOY_USER git clone https://github.com/rbenv/ruby-build.git /home/$DEPLOY_USER/.rbenv/plugins/ruby-build
sudo -u $DEPLOY_USER git clone https://github.com/rbenv/rbenv-vars.git /home/$DEPLOY_USER/.rbenv/plugins/rbenv-vars
echo "✅ Done"

# RUBY

echo "----------"
echo "Installing Ruby for deploy user ..."
rubyversion=$(cat .ruby-version)
echo $rubyversion
# On Mac you can simply run `rbenv install`. On Debian we must specify the exact version.
sudo -u $DEPLOY_USER bash -lc "rbenv install $rubyversion --skip-existing"
echo "✅ Done"

# BUNDLER

# https://bundler.io/blog/2022/01/23/bundler-v2-3.html
# https://bundler.io/blog/2019/05/14/solutions-for-cant-find-gem-bundler-with-executable-bundle.html
# Until Bundler 2.3 we need to install the exact version ourselves.

echo "----------"
echo "Installing Bundler v$bundlerversion for deploy user ..."
sudo -u $DEPLOY_USER bash -lc "gem install bundler -v \"$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)\""
echo "✅ Done"

# GEMS

echo "----------"
echo "Installing gems for deploy user ..."
sudo -u $DEPLOY_USER bash -lc "bundle install"
echo "✅ Done"

# SECRETS

echo "----------"
echo "Enter the config/credentials/production.key:"
read -s PRODUCTION_KEY
echo $PRODUCTION_KEY >> config/credentials/production.key
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
sudo -u $DEPLOY_USER bash -lc "bin/rails db:create"
echo "✅ Done"

# DATABASE SCHEMA

echo "----------"
echo "Apply database schema..."
sudo -u $DEPLOY_USER bash -lc "bin/rails db:schema:load"
echo "✅ Done"

# PUMA

echo "----------"
echo "Configuring Puma service"
sudo ln -s /var/www/$DOMAIN/config/puma.service /etc/systemd/system/$DEPLOY_USER.service
sudo systemctl daemon-reload
echo "✅ Done"

echo "----------"
echo "Starting Puma service"
sudo systemctl start $DEPLOY_USER
sudo systemctl status $DEPLOY_USER --no-pager
echo "✅ Done"