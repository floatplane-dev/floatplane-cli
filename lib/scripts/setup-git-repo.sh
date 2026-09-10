#!/bin/bash

set -eou pipefail

DOMAIN=$1
DEPLOY_USER=bot
SUDO_USER=admin

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

if [ -d "/var/www/$DOMAIN" ]; then
  echo "----------"
  echo "✅ Git repo already exists"
  echo "----------"
  echo "Pulling latest code ..."
  cd /var/www/$DOMAIN
  sudo -u $DEPLOY_USER bash -lc 'git reset --hard'
  sudo -u $DEPLOY_USER bash -lc 'git checkout production'
  sudo -u $DEPLOY_USER bash -lc 'git pull'
  echo "✅ done"
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
  sudo mkdir -p /home/$DEPLOY_USER/.ssh
  sudo ssh-keygen -t rsa -b 4096 -C "$DEPLOY_USER@$DOMAIN" -f /home/$DEPLOY_USER/.ssh/$DEPLOY_USER@$DOMAIN -P ""
  sudo chown -R $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/.ssh
  echo "----------"
  sudo cat /home/$DEPLOY_USER/.ssh/$DEPLOY_USER@$DOMAIN.pub
  echo "----------"
  echo "ACTION REQUIRED:"
  echo "1. Copy the public key above"
  echo "2. Open Github and go to the repository of $DOMAIN"
  echo "3. Add public key as read-only deploy key"
  echo "4. Done?"
  wait_until_yes
  echo "----------"
  echo "Does this git repo have a production branch?"
  wait_until_yes
  echo "----------"
  echo "Creating new Git repo ..."
  mkdir /var/www/$DOMAIN
  cd /var/www/$DOMAIN
  git init --initial-branch=main
  git remote add origin $repo
  echo "✅ done"
  echo "----------"
  echo "Configuring global user name and email"
  git config --global user.email "$DEPLOY_USER@$DOMAIN"
  git config --global user.name "$DEPLOY_USER@$DOMAIN"
  echo "✅ done"
  echo "----------"
  echo "Configuring Git to use the new SSH key ..."
  git config core.sshCommand "ssh -i /home/$DEPLOY_USER/.ssh/$DEPLOY_USER@$DOMAIN -F /dev/null"
  echo "✅ done"
  echo "----------"
  echo "Make deploy user owner of domain root ..."
  sudo chown -R $DEPLOY_USER:$DEPLOY_USER /var/www/$DOMAIN
  echo "✅ done"
  echo "----------"
  echo "Grant sudo user access to domain root ..."
  sudo setfacl -R -m u:$SUDO_USER:rwx /var/www/$DOMAIN/
  sudo setfacl -R -d -m u:$SUDO_USER:rwx /var/www/$DOMAIN/
  sudo getfacl /var/www/$DOMAIN/
  echo "✅ done"
  echo "----------"
  echo "Pulling latest production code ..."
  sudo -u $DEPLOY_USER bash -lc 'git fetch'
  echo "✅ done"
  echo "----------"
  echo "Checking out production ..."
  sudo -u $DEPLOY_USER bash -lc 'git checkout production'
  echo "✅ done"
  echo "----------"
  echo "Setting default merge strategy ..."
  sudo -u $DEPLOY_USER bash -lc 'git config pull.rebase false'
  echo "✅ done"
  echo "----------"
  echo "✅ Created git repo 🦑"
  echo "----------"
fi

