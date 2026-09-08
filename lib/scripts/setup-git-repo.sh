#!/bin/bash

set -eou pipefail

domain=$1
deploy=$2

wait_until_yes() {
  while true; do
  select answer in yes no; do
      case $answer in
      yes) break 2;;
      no)  echo "Please do so now";;
      *)   echo "Invalid choice";;
      esac
  done
  done
}

if [ -d "/var/www/$domain" ]; then
  echo "----------"
  echo "✅ Git repo already exists"
  echo "----------"
else
  echo "----------"
  echo "Creating git repo 🦑"
  echo "----------"
  echo "Enter the Github SSH URL (git@github.com:floatplane-dev/some-codebase.git):"
  while true; do
    read repo
    if [[ $repo == git@github.com:* ]]; then
      break;
    else
      echo "Please enter a URL which starts with git@github.com:."
    fi
  done
  echo "----------"
  echo "Generating SSH key for deploy user ..."
  sudo mkdir -p /home/$deploy/.ssh
  sudo ssh-keygen -t rsa -b 4096 -C "$deploy@$domain" -f /home/$deploy/.ssh/$deploy@$domain -P ""
  sudo chown -R $deploy:$deploy /home/$deploy/.ssh
  echo "----------"
  sudo cat /home/$deploy/.ssh/$deploy@$domain.pub
  echo "----------"
  echo "ACTION REQUIRED:"
  echo "1. Copy the public key above"
  echo "2. Open Github and go to the repository of $domain"
  echo "3. Add public key as read-only deploy key"
  echo "4. Done?"
  wait_until_yes
  echo "----------"
  echo "Does this git repo have a production branch?"
  wait_until_yes
  echo "----------"
  echo "Creating new Git repo ..."
  mkdir /var/www/$domain
  cd /var/www/$domain
  git init --initial-branch=main
  git remote add origin $repo
  echo "✅ done"
  echo "----------"
  echo "Configuring global user name and email"
  git config --global user.email "$deploy@$domain"
  git config --global user.name "$deploy@$domain"
  echo "✅ done"
  echo "----------"
  echo "Configuring Git to use the new SSH key ..."
  git config core.sshCommand "ssh -i /home/$deploy/.ssh/$deploy@$domain -F /dev/null"
  echo "✅ done"
  echo "----------"
  echo "Make deploy user owner of domain root ..."
  sudo chown -R $deploy:$deploy /var/www/$domain
  echo "✅ done"
  echo "----------"
  echo "Grant admin access to domain root ..."
  sudo setfacl -R -m u:admin:rwx /var/www/$domain/
  sudo setfacl -R -d -m u:admin:rwx /var/www/$domain/
  sudo getfacl /var/www/$domain/
  echo "✅ done"
  echo "----------"
  echo "Pulling latest production code ..."
  sudo -u $deploy bash -lc 'git fetch'
  echo "✅ done"
  echo "----------"
  echo "Checking out production ..."
  sudo -u $deploy bash -lc 'git checkout production'
  echo "✅ done"
  echo "----------"
  echo "Setting default merge strategy ..."
  sudo -u $deploy bash -lc 'git config pull.rebase false'
  echo "✅ done"
  echo "----------"
  echo "✅ Created git repo 🦑"
  echo "----------"
fi

