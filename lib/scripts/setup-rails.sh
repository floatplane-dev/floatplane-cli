#!/bin/bash

set -eou pipefail

domain=$1
repo=$2
redirect_www=$3

echo "Setting up Rails project 🐹 ..."
echo "domain=$domain"
echo "repo=$repo"
echo "----------"
echo "Removing existing setup ..."
rm -rf ~/.ssh/bot@$domain
rm -rf /var/www/$domain
rm -rf /etc/nginx/sites-enabled/$domain.conf
echo "----------"
echo "Generating new SSH key ..."
ssh-keygen -t rsa -b 4096 -C "readonly@$domain" -f ~/.ssh/readonly@$domain -P ""
cat ~/.ssh/readonly@$domain.pub
echo "----------"
echo "ACTION REQUIRED:"
echo "1. Please copy the public key above."
echo "2. Open Github and go to the repository of $domain."
echo "3. Add public key as read-only deploy key."
echo "4. Done? y/n"

while :
do
read -s -n 1 input
case $input in
  y)
    echo "Done!"
    break;
    ;;
  n)
    echo "Quit"
    exit 0;
    ;;
esac
done

echo "----------"
echo "Cloning repo ..."
(
  set -x
  GIT_SSH_COMMAND="ssh -i ~/.ssh/readonly@$domain" git clone $repo /var/www/$domain
)
echo "----------"
echo "Enter repo directory ..."
echo "cd /var/www/$domain"
cd /var/www/$domain
echo "----------"
echo "Configuring Git SSH to use the readonly SSH key ..."
(
  set -x
  git config core.sshCommand "ssh -i ~/.ssh/readonly@$domain -F /dev/null"
)
echo "----------"
echo "Pulling latest production code ..."
(
  set -x
  git checkout production
  git pull
)

echo "DONE BRO"

exit 0;

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

# NGINX, CERTBOT, HTTPS CERTIFICATES


echo "----------"
echo "Configuring Nginx for HTTP..."
( set -x; sudo ln -nsf /var/www/$domain/nginx/$domain.temp.conf /etc/nginx/sites-enabled/$domain.conf )

echo "----------"
echo "Testing Nginx configs..."
( set -x; sudo nginx -t )

echo "----------"
echo "Restarting Nginx..."
( set -x; sudo systemctl restart nginx )

echo "----------"
echo "Creating SSL certificates..."
(
  set -x
  sudo certbot certonly --nginx -d $domain
  if [ "$redirect_www" = true ] ; then
    echo "Creating extra certificate for redirecting www"
    sudo certbot certonly --nginx -d www.$domain
  fi
)

echo "----------"
echo "Configuring Nginx for HTTPS..."
( set -x; sudo ln -nsf /var/www/$domain/nginx/$domain.conf /etc/nginx/sites-enabled/$domain.conf )

echo "----------"
echo "Testing Nginx configs... (again)"
( set -x; sudo nginx -t )

echo "----------"
echo "Restarting Nginx... (again)"
( set -x; sudo systemctl restart nginx )

echo "----------"
echo "Done!"
echo "----------"
echo "NEXT STEPS"
echo "👉🏼 Hit the API with curl to sanity test if live."
echo "👉🏼 Manually seed the database with data."
echo "👉🏼 Set up automated tests and deploys (CI/CD)"
echo "----------"
