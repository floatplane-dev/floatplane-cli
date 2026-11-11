#!/bin/bash

set -eou pipefail

APP_DIR="${1:-.}"

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

echo "Setting up app 🌱"

if [ -f "$APP_DIR/.fprc" ]; then
  source "$APP_DIR/.fprc"
else
  touch "$APP_DIR/.fprc"
fi

if [ -z "${SSH_HOST:-}" ]; then
  echo "----------"
  echo "On which server? 🗿"
  echo "Enter the SSH alias (e.g. melbourne, amsterdam, ...)"
  read SSH_HOST
  echo "SSH_HOST=$SSH_HOST" >> "$APP_DIR/.fprc"
fi

if [ -z "${TECH:-}" ]; then
  echo "----------"
  echo "What kind of app?"
  options[0]="rails"
  options[1]="svelte"
  options[2]="html"
  # options[2]="Ember 🐹"
  # options[3]="Deno 🦕"
  # options[4]="Gulp 🍹"
  select TECH in "${options[@]}"
  do
    if [[ "${options[*]}" =~ "${TECH}" ]]; then
      break
    else
      echo "Please enter a number from the list."
    fi
  done
  echo "TECH=$TECH" >> "$APP_DIR/.fprc"
fi

if [ -z "${DOMAIN:-}" ]; then
  echo "----------"
  echo "What's the main domain name of the app? 🥦 (foo.com)"
  read DOMAIN
  echo "DOMAIN=$DOMAIN" >> "$APP_DIR/.fprc"
fi

if [ -z "${REDIRECT_WWW:-}" ]; then
  echo "----------"
  echo "Does www.$DOMAIN need to redirect to $DOMAIN? 🪃 (true/false)"
  wait_until_yes
  echo "REDIRECT_WWW=true" >> "$APP_DIR/.fprc"
fi

if [ -z "${CA:-}" ]; then
  echo "----------"
  echo "Choose the Certificate Authority (CA) for TLS 🔒"
  options=()
  options[0]="Cloudflare"
  options[1]="Let's Encrypt"
  select CA in "${options[@]}"
  do
    if [[ "${options[*]}" =~ "${CA}" ]]; then
      break
    else
      echo "Please enter a number from the list."
    fi
  done
  echo "CA=$CA" >> "$APP_DIR/.fprc"
fi

if [ -z "${DOMAIN_READY:-}" ]; then
  echo "----------"
  echo "Do the A and AAAA records of $DOMAIN point to the IP of server $SSH_HOST? 👉"
  wait_until_yes
  
  if [ "$REDIRECT_WWW" = true ] ; then
    echo "----------"
    echo "Do the A and AAAA records of www.$DOMAIN point to the IP of server $SSH_HOST? 👈"
    wait_until_yes
  fi

  if [ "$CA" = "Cloudflare" ] ; then
    echo "----------"
    echo "Has $DOMAIN's TLS encryption mode been set to Full (strict)?"
    wait_until_yes
    echo "----------"
    echo "Is $DOMAIN's being proxied? (orange cloud, not grey DNS only)"
    wait_until_yes
    if [ "$REDIRECT_WWW" = true ] ; then
      echo "----------"
      echo "Is www.$DOMAIN's being proxied? (orange cloud, not grey DNS only)"
      wait_until_yes
    fi
  fi

  echo "DOMAIN_READY=true" >> "$APP_DIR/.fprc"
fi

echo "----------"
echo "✅ domain name is ready"

# --------------------------------------------------------------------------------------------------

if [[ $TECH == "rails" ]]; then

  if [ -z "${CODE_READY:-}" ]; then
    echo "----------"
    echo "Does the codebase have the following?"
    echo "✅ production git branch"
    echo "✅ .ruby-version"
    echo "✅ config/credentials/production.yml.enc"
    echo "✅ config/puma.service"
    echo "✅ nginx/$DOMAIN.conf"
    echo "✅ tmp/sockets/.keep"
    echo "✅ tmp/pids/.keep"

    wait_until_yes

    echo "CODE_READY=true" >> "$APP_DIR/.fprc"
    echo "----------"
    echo "✅ Code base is ready"
  fi

  echo "----------"
  echo "Connecting to $SSH_HOST ..."
  echo "----------"

  scp ./setup-deploy-user.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-deploy-user.sh"

  scp ./setup-logs.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-logs.sh $DOMAIN"

  scp ./setup-git-repo.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-git-repo.sh $DOMAIN"

  scp ./setup-rails.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-rails.sh $DOMAIN"

  scp ./setup-nginx.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-nginx.sh $DOMAIN $CA $REDIRECT_WWW"

  echo "----------"
  echo "✅ Done"
  echo "----------"
  echo "NEXT STEPS"
  echo "👉🏼 Hit the API with curl to sanity test if live."
  echo "👉🏼 Manually seed the database with data."
  echo "👉🏼 Set up automated tests and deploys (CI/CD)"
  echo "----------"
fi

# --------------------------------------------------------------------------------------------------

if [[ $TECH == "svelte" ]]; then
  if [ -z "${CODE_READY:-}" ]; then
    echo "----------"
    echo "Does the codebase have the following?"
    echo "✅ production git branch"
    echo "✅ @svelte/adaptor-node"
    echo "✅ .env.example"
    echo "✅ systemd.service"
    echo "✅ nginx/$DOMAIN.conf"

    wait_until_yes

    echo "CODE_READY=true" >> "$APP_DIR/.fprc"
  fi
  echo "----------"
  echo "✅ code base is ready"
  echo "----------"
  echo "Connecting to $SSH_HOST ..."
  echo "----------"
  if [ -z "${DEPLOY_USER_READY:-}" ]; then
    scp ./setup-deploy-user.sh $SSH_HOST:~/
    ssh -t $SSH_HOST "~/setup-deploy-user.sh"
    echo "DEPLOY_USER_READY=true" >> "$APP_DIR/.fprc"
  fi
  echo "----------"
  echo "✅ deploy user is ready"
  if [ -z "${LOGS_READY:-}" ]; then
    scp ./setup-logs.sh $SSH_HOST:~/
    ssh -t $SSH_HOST "~/setup-logs.sh $DOMAIN"
    echo "LOGS_READY=true" >> "$APP_DIR/.fprc"
  fi
  echo "----------"
  echo "✅ logs are ready"
  if [ -z "${REPO_READY:-}" ]; then
    scp ./setup-git-repo.sh $SSH_HOST:~/
    ssh -t $SSH_HOST "~/setup-git-repo.sh $DOMAIN"
    echo "REPO_READY=true" >> "$APP_DIR/.fprc"
  fi
  echo "----------"
  echo "✅ git repo is ready"
  if [ -z "${NODE_READY:-}" ]; then
    scp ./setup-nvm.sh $SSH_HOST:~/
    ssh -t $SSH_HOST "~/setup-nvm.sh"
    echo "NODE_READY=true" >> "$APP_DIR/.fprc"
  fi
  echo "----------"
  echo "✅ Node is ready"
  if [ -z "${SVELTE_READY:-}" ]; then
    scp ./setup-svelte.sh $SSH_HOST:~/
    ssh -t $SSH_HOST "~/setup-svelte.sh $DOMAIN $SSH_HOST"
    echo "SVELTE_READY=true" >> "$APP_DIR/.fprc"
  fi
  echo "----------"
  echo "✅ Svelte is ready"
  if [ -z "${NGINX_READY:-}" ]; then
    scp ./setup-nginx.sh $SSH_HOST:~/
    ssh -t $SSH_HOST "~/setup-nginx.sh $DOMAIN $CA $REDIRECT_WWW"
    echo "NGINX_READY=true" >> "$APP_DIR/.fprc"
  fi
  echo "----------"
  echo "✅ Nginx is ready"
  echo "----------"
  echo "✅ Done"
  echo "----------"
  echo "FINAL STEP:"
  echo "👉🏼 Open $DOMAIN in your browser. Check whether all is working!"
  sleep 1
  echo "3"
  sleep 1
  echo "2"
  sleep 1
  echo "1"
  sleep 1
  open https://$DOMAIN
  echo "----------"
fi

# --------------------------------------------------------------------------------------------------

if [[ $TECH == "html" ]]; then

  if [ -z "${CODE_READY:-}" ]; then
    echo "----------"
    echo "Have you done the following?"
    echo "✅ production git branch"

    wait_until_yes

    echo "----------"
    echo "✅ Code base is ready"
  fi

  echo "----------"
  echo "Connecting to $SSH_HOST ..."
  echo "----------"
  
  scp ./setup-deploy-user.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-deploy-user.sh"

  scp ./setup-logs.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-logs.sh $DOMAIN"

  scp ./setup-git-repo.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-git-repo.sh $DOMAIN"

  scp ./setup-nginx.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-nginx.sh $DOMAIN $CA $REDIRECT_WWW"

  echo "----------"
  echo "✅ Done"
  echo "----------"
  echo "FINAL STEP:"
  echo "👉🏼 Open $DOMAIN in your browser. Check whether all is working!"
  sleep 1
  echo "3"
  sleep 1
  echo "2"
  sleep 1
  echo "1"
  sleep 1
  open https://$DOMAIN
  echo "----------"
fi

echo "----------"
echo "App setup complete 🌱"
echo "----------"
