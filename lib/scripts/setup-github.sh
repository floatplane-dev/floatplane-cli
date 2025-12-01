#!/bin/bash

set -eou pipefail

domain=$1

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

echo "----------"
echo "Setting up Github code repository 🦑"

# Generate SSH key, if it does not yet exist
if [ ! -f ~/.ssh/readonly@$domain ]; then
  echo "----------"
  echo "Generating new SSH key ..."
  ssh-keygen -t rsa -b 4096 -C "readonly@$domain" -f ~/.ssh/readonly@$domain -P ""
  cat ~/.ssh/readonly@$domain.pub
  echo "----------"
  echo "ACTION REQUIRED:"
  echo "1. Please copy the public key above."
  echo "2. Open Github and go to the repository of $domain."
  echo "3. Add public key as read-only deploy key."
  echo "4. Done?"
  wait_until_yes
fi

# Clone the repo, if it does not yet exist
if [ ! -d /var/www/$domain ]; then
  echo "----------"
  echo "What's the Github SSH URL of this project? 🦑 (git@github.com:floatplane-dev/some-project.git)"
  while true; do
    read repo
    if [[ $repo == git@github.com:* ]]; then
      break;
    else
      echo "Please enter a URL which starts with git@github.com:."
    fi
  done
  echo "----------"
  echo "Cloning repo ..."
  GIT_SSH_COMMAND="ssh -i ~/.ssh/readonly@$domain" git clone $repo /var/www/$domain
  echo "----------"
  echo "Configuring Git SSH to use the readonly SSH key ..."
  cd /var/www/$domain
  git config core.sshCommand "ssh -i ~/.ssh/readonly@$domain -F /dev/null"
fi

echo "----------"
echo "Pulling latest production code ..."
cd /var/www/$domain
git checkout production
git pull