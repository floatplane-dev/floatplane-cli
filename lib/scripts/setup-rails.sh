#!/bin/bash

set -e

domain=$1

echo "----------"
echo "Setting up Rails 🛤️ ..."
echo "----------"
echo "Changing directory ..."
cd /var/www/$domain
echo "----------"

# RBENV

# should already have been installed during server setup

# RUBY

echo "----------"
echo "Installing Ruby ..."
rubyversion=$(cat .ruby-version)
echo $rubyversion
rbenv install $rubyversion --skip-existing
# Works on Mac, but not on Debian
# rbenv install --skip-existing

# Set this version as the default
# rbenv local $rubyversion
# TODO: no longer needed?

# BUNDLER

# https://bundler.io/blog/2022/01/23/bundler-v2-3.html
# https://bundler.io/blog/2019/05/14/solutions-for-cant-find-gem-bundler-with-executable-bundle.html
# Until Bundler 2.3 we need to install the exact version ourselves.
# gem install bundler:2.4.6

echo "----------"
echo "Installing Bundler ..."
bundlerversion=$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)
echo $bundlerversion
gem install bundler -v $bundlerversion

# GEMS

echo "----------"
echo "Installing gems ..."
bundle install

# POSTGRESS

# Postgress should already have been installed during server setup.

# POSTGRESS USER

if sudo -u postgres psql -t -c '\du' | cut -d \| -f 1 | grep -qw admin; then
  echo "----------"
  echo "Skipping Postgres user setup"
else
  echo "----------"
  echo "Creating Postgres user named \"admin\"..."
  sudo -u postgres createuser -s admin
  echo "----------"
  echo "Please enter a secure password for this user and store in password manager:"
  read -s postgres_admin_password
  sudo -u postgres psql -c "ALTER USER admin WITH PASSWORD '$postgres_admin_password';"
fi

# SET UP SECRETS

# Documentation on how to set up Rails credentials and master key:
# https://gist.github.com/db0sch/19c321cbc727917bc0e12849a7565af9
echo "----------"
echo "Please enter the config/master.key:"
read -s master_key
echo $master_key >> config/master.key
echo "----------"
echo "Please enter the production environment secrets for .rbenv-vars. Use the following format:"
cat .rbenv-vars.example
read -s rbenv_vars
echo $rbenv_vars >> .rbenv-vars

# CREATE DATABASE

echo "----------"
echo "Creating database ..."
export RAILS_ENV=production
bin/rails db:create

# DATABASE SCHEMA

echo "----------"
echo "Apply database schema..."
bin/rails db:schema:load

# PUMA

bin/puma -e production