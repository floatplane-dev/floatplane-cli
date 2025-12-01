#!/bin/bash

set -e

domain=$1
deploy=$2

# DEPLOY USER

# IMPORTANT: Why bother with a deploy user? 
# Running Puma with the admin user, which has sudo powers, allows Rails to run commands as admin.
# This is considered bad practice. Instead we ought to create a "deploy" user which has only the
# few privileges needed for Puma to run the Rails app via systemd.

echo "----------"
echo "Creating deploy user with name "$deploy" 🤖 ..."
echo "----------"

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
