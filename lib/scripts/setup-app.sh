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
echo "----------"

if [ -f "$APP_DIR/.fprc" ]; then
  source "$APP_DIR/.fprc"
fi

if [ -z "${SSH_HOST:-}" ] || [ -z "${DOMAIN:-}" ] || [ -z "${TECH:-}" ]; then
  echo "On which server? 🚀"
  echo "Enter the SSH alias (e.g. melbourne, amsterdam, ...)"
  read SSH_HOST

  # ssh_aliases=(`grep "^Host " ~/.ssh/config | awk '{print $2}' | sort -u`)
  # select ssh_alias in "${ssh_aliases[@]}"; do
  #   [ "$ssh_alias" ] && break
  #   echo "Please enter a number from the list."
  # done
  # 
  # HAS ODD BUG
  # ----------
  # 1) setup-deno.sh	   9) setup-server-1.sh	    17) frankfurt
  # 2) setup-ember.sh	  10) setup-server-2.sh	    18) github.com
  # 3) setup-git-repo.sh	  11) setup-server-3.sh	    19) madrid
  # 4) setup-gulp.sh	  12) setup-server-4.sh	    20) melbourne
  # 5) setup-logrotation.sh	  13) setup-server-5.sh	    21) mexico
  # 6) setup-nginx.sh	  14) setup-server.sh	    22) osaka
  # 7) setup-app.sh	  15) setup.sh		    23) paris
  # 8) setup-rails.sh	  16) amsterdam

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

  

  echo "----------"
  echo "What's the main domain name of the app? ⛵ (foo.com)"
  read DOMAIN

  cat > "$APP_DIR/.fprc" <<EOF
SSH_HOST=$SSH_HOST
DOMAIN=$DOMAIN
TECH=$TECH
EOF
fi

echo "----------"
echo "Connecting to $SSH_HOST ..."
echo "----------"

if [[ $TECH == "rails" ]]; then
  echo "----------"
  echo "Does the production branch of your Rails codebase have all of these?"
  echo " ↳ .ruby-version"
  echo " ↳ config/credentials/production.yml.enc"
  echo " ↳ config/puma.service"
  echo " ↳ nginx/$DOMAIN.conf"
  echo " ↳ GET /api/sanity-check"

  wait_until_yes

  echo "----------"
  echo "✅ Code base is ready"
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
  ssh -t $SSH_HOST "~/setup-nginx.sh $DOMAIN"

  echo "----------"
  echo "✅ Done"
  echo "----------"
  echo "NEXT STEPS"
  echo "👉🏼 Hit the API with curl to sanity test if live."
  echo "👉🏼 Manually seed the database with data."
  echo "👉🏼 Set up automated tests and deploys (CI/CD)"
  echo "----------"
fi

if [[ $TECH == "svelte" ]]; then
  echo "----------"
  echo "Have you done the following? 🥦"
  echo "👉🏼 Created git branch named: production"
  echo "👉🏼 @svelte/adaptor-node"
  echo "👉🏼 .env.example"
  echo "👉🏼 systemd.service"
  echo "👉🏼 nginx/$DOMAIN.conf"

  wait_until_yes

  echo "----------"
  echo "✅ Code base is ready"
  echo "----------"

  scp ./setup-deploy-user.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-deploy-user.sh"

  scp ./setup-logs.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-logs.sh $DOMAIN"

  scp ./setup-git-repo.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-git-repo.sh $DOMAIN"

  scp ./setup-nvm.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-nvm.sh"

  scp ./setup-svelte.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-svelte.sh $DOMAIN $SSH_HOST"

  scp ./setup-nginx.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-nginx.sh $DOMAIN"

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

if [[ $TECH == "html" ]]; then
  echo "----------"
  echo "Have you done the following? 🥦"
  echo "👉🏼 Created git branch named: production"

  wait_until_yes

  echo "----------"
  echo "✅ Code base is ready"
  echo "----------"

  scp ./setup-deploy-user.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-deploy-user.sh"

  scp ./setup-logs.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-logs.sh $DOMAIN"

  scp ./setup-git-repo.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-git-repo.sh $DOMAIN"

  scp ./setup-nginx.sh $SSH_HOST:~/
  ssh -t $SSH_HOST "~/setup-nginx.sh $DOMAIN"

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
