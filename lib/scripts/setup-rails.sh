#!/bin/bash

set -eou pipefail

domain=$1

echo "Setting up Rails project 🛤️ ..."
echo "domain=$domain"

# RBENV

# should already have been installed during server setup

# RUBY

echo "----------"
echo "Installing Ruby ..."
rbenv install --skip-existing

# BUNDLER

# https://bundler.io/blog/2022/01/23/bundler-v2-3.html
# https://bundler.io/blog/2019/05/14/solutions-for-cant-find-gem-bundler-with-executable-bundle.html
# Until Bundler 2.3 we need to install the exact version ourselves.
# gem install bundler:2.4.6

echo "----------"
echo "Installing Bundler ..."
gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)"

# GEMS

echo "----------"
echo "Installing gems ..."
bundle install

# POSTGRESS

# Postgress should already have been installed during server setup.

# POSTGRESS USER

echo "----------"
echo "Creating Postgres user named \"admin\"..."
sudo -u postgres createuser -s admin

echo "----------"
echo "Please enter a secure password for this user and store in password manager:"
read -s postgres_admin_password
sudo -u postgres psql -c "ALTER USER admin WITH PASSWORD '$postgres_admin_password';"

# SET UP SECRETS

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