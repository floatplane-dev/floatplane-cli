#!/bin/bash

set -e

DOMAIN=$1
DEPLOY_USER=bot

echo "----------"
echo "Setting up Rails 🛤️ ..."

# PACKAGES

echo "----------"
echo "Refreshing local package catalog ..."
sudo apt update
echo "----------"
echo "Installing Postgres ..."
sudo apt install -y postgresql postgresql-contrib libpq-dev
echo "✅ Done"
echo "----------"
echo "Installing missing packages for compiling Ruby ..."
sudo apt install -y build-essential libssl-dev libreadline-dev zlib1g-dev libtool libyaml-dev
echo "✅ Done"

# DIRECTORY

echo "----------"
echo "Changing directory ..."
cd /var/www/$DOMAIN
echo "✅ Done"

# RBENV

if ! sudo -u $DEPLOY_USER test -d /home/$DEPLOY_USER/.rbenv; then
    echo "----------"
    echo "Cloning rbenv ..."
    sudo -u $DEPLOY_USER git clone https://github.com/rbenv/rbenv.git /home/$DEPLOY_USER/.rbenv
    echo "✅ Done"
else
    echo "----------"
    echo "✅ rbenv has already been cloned, skipping"
fi

if ! sudo -u $DEPLOY_USER grep -q 'rbenv init' /home/$DEPLOY_USER/.bash_profile 2>/dev/null; then
    echo "----------"
    echo "Adding rbenv to PATH ..."

    # Normally running `rbenv init` should be sufficient, but fails here.
    # Therefor we manually do what `rbenv init` would have done to make `rbenv` available in PATH.

    sudo -u $DEPLOY_USER bash -c 'echo "eval \"\$(~/.rbenv/bin/rbenv init - --no-rehash bash)\"" >> ~/.bash_profile'
    echo "✅ Done"
else
    echo "----------"
    echo "✅ rbenv is available in PATH, skipping"
fi

# RUBY BUILD

if ! sudo -u $DEPLOY_USER test -d /home/$DEPLOY_USER/.rbenv/plugins/ruby-build; then
    echo "----------"
    echo "Installing ruby-build plugin for deploy user ..."
    sudo -u $DEPLOY_USER mkdir -p /home/$DEPLOY_USER/.rbenv/plugins
    sudo -u $DEPLOY_USER git clone https://github.com/rbenv/ruby-build.git /home/$DEPLOY_USER/.rbenv/plugins/ruby-build
    echo "✅ Done"
else
    echo "----------"
    echo "✅ ruby-build already exists, skipping"
fi

# RBENV VARS

if ! sudo -u $DEPLOY_USER test -d /home/$DEPLOY_USER/.rbenv/plugins/rbenv-vars; then
    echo "----------"
    echo "Installing rbenv-vars plugin for deploy user ..."
    sudo -u $DEPLOY_USER mkdir -p /home/$DEPLOY_USER/.rbenv/plugins
    sudo -u $DEPLOY_USER git clone https://github.com/rbenv/rbenv-vars.git /home/$DEPLOY_USER/.rbenv/plugins/rbenv-vars
    echo "✅ Done"
else
    echo "----------"
    echo "✅ rbenv-vars already exists, skipping"
fi

# RUBY

echo "----------"
echo "Installing Ruby ..."
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
echo "Installing Bundler v$bundlerversion ..."
sudo -u $DEPLOY_USER bash -lc "gem install bundler -v \"$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)\""
echo "✅ Done"

# GEMS

echo "----------"
echo "Installing gems ..."
sudo -u $DEPLOY_USER bash -lc "bundle install"
echo "✅ Done"

# SECRETS

if [ ! -f config/credentials/production.key ]; then
    echo "----------"
    echo "Enter the config/credentials/production.key:"
    read -s PRODUCTION_KEY
    echo $PRODUCTION_KEY >> config/credentials/production.key
    echo "✅ Done"
else
    echo "----------"
    echo "✅ production.key already exists, skipping"
fi

# ENVIRONMENT

# The .rbenv-vars below makes all other commands run in production mode.
# No more need to prepend `RAILS_ENV=production` to all commands.
# No more need to append `-e production` to `rails` commands`
# Simply run:
# * bin/rails c
# * bin/rails db:migrate
# * bin/puma -C config/puma.rb

if ! grep -q '^RAILS_ENV=' .rbenv-vars 2>/dev/null; then
    echo "----------"
    echo "Setting RAILS_ENV=production on rbenv-vars"
    echo "RAILS_ENV=production" >> .rbenv-vars
    echo "✅ Done"
else
    echo "----------"
    echo "✅ RAILS_ENV already set, skipping"
fi

# POSTGRES USER

if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DEPLOY_USER'" | grep -q 1; then
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
else
    echo "----------"
    echo "✅ Postgres user \"$DEPLOY_USER\" already exists, skipping"
fi

# CREATE DATABASE

echo "----------"
echo "Creating database ..."
sudo -u $DEPLOY_USER bash -lc "bin/rails db:prepare"

# NOTE:
# rails db:prepare is a shorthand for:
# rails db:create && rails db:schema:load` if database is absent
# rails:db:migrate if database is present

echo "✅ Done"

# PUMA

if [ ! -e /etc/systemd/system/$DOMAIN.service ]; then
    echo "----------"
    echo "Sym linking Puma to systemd ..."
    sudo ln -s /var/www/$DOMAIN/config/puma.service /etc/systemd/system/$DOMAIN.service
    echo "✅ Done"
else
    echo "----------"
    echo "✅ Puma is already sym linked to systemd, skipping"
fi

echo "----------"
echo "Stopping Puma service ... (if any)"
sudo systemctl stop $DOMAIN
echo "----------"
echo "Reloading daemons (for possible changes)"
sudo systemctl daemon-reload
echo "----------"
echo "Starting Puma service ..."
sudo systemctl start $DOMAIN
echo "----------"
echo "Status Puma service:"
sudo systemctl status $DOMAIN --no-pager
echo "✅ Done"