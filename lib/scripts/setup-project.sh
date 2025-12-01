#!/bin/bash

set -eou pipefail

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

echo "Setting up project 🌱"
echo "----------"
echo "On which server? 🚀"
echo "Enter the SSH alias (e.g. melbourne, amsterdam, ...)"
read server

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
# 3) setup-github.sh	  11) setup-server-3.sh	    19) madrid
# 4) setup-gulp.sh	  12) setup-server-4.sh	    20) melbourne
# 5) setup-logrotation.sh	  13) setup-server-5.sh	    21) mexico
# 6) setup-nginx.sh	  14) setup-server.sh	    22) osaka
# 7) setup-project.sh	  15) setup.sh		    23) paris
# 8) setup-rails.sh	  16) amsterdam

echo "----------"
echo "What kind of project?"

options[0]="Ember 🐹"
options[1]="Deno 🦕"
options[2]="Rails 🛤️"
options[3]="Gulp 🍹"
select tech in "${options[@]}"
do
  if [[ "${options[*]}" =~ "${tech}" ]]; then
    break
  else
    echo "Please enter a number from the list."
  fi
done

echo "----------"
echo "What's the main domain name of the project? ⛵ (foo.com)"
read domain
echo "----------"
echo "Connecting to $server ..."
echo "----------"

if [[ $tech == "Ember 🐹" ]]; then
  scp ./setup-github.sh $server:~/
  ssh -t $server "~/setup-github.sh $domain"
  scp ./setup-ember.sh $server:~/
  ssh -t $server "~/setup-ember.sh $domain"
  scp ./setup-nginx.sh $server:~/
  ssh -t $server "~/setup-nginx.sh $domain"
  echo "----------"
  echo "Done!"
  echo "----------"
  echo "FINAL STEP:"
  echo "👉🏼 Open $domain in your browser. Check whether all is working!"
  sleep 1
  echo "3"
  sleep 1
  echo "2"
  sleep 1
  echo "1"
  sleep 1
  open https://$domain
  echo "----------"
fi

if [[ $tech == "Deno 🦕" ]]; then
  scp ./setup-github.sh $server:~/
  ssh -t $server "~/setup-github.sh $domain"
  scp ./setup-deno.sh $server:~/
  ssh -t $server "~/setup-deno.sh $domain"
  scp ./setup-nginx.sh $server:~/
  ssh -t $server "~/setup-nginx.sh $domain"
  echo "----------"
  echo "Done!"
  echo "----------"
  echo "Possible next steps:"
  echo "👉🏼 Check if Deno API is alive with: curl https://$domain/sanity-check"
  echo "👉🏼 Populate the database"
  echo "----------"
fi

if [[ $tech == "Rails 🛤️" ]]; then

  # PREREQUISITES

  echo "Does the production branch of your Rails codebase have all of these?"
  echo "✅ .ruby-version"
  echo "✅ config/credentials/production.yml.enc"
  echo "✅ config/puma.service"
  echo "✅ nginx/$domain.conf"
  echo "✅ GET /api/sanity-check"

  wait_until_yes

  echo "----------"
  echo "Choose short name for deploy user (e.g.: interflux, piccolo, ...):"
  read deploy
  echo "----------"
  scp ./setup-deploy-user.sh $server:~/
  ssh -t $server "~/setup-deploy-user.sh $domain $deploy"
  scp ./setup-logs.sh $server:~/
  ssh -t $server "~/setup-logs.sh $domain $deploy"
  scp ./setup-github.sh $server:~/
  ssh -t $server "~/setup-github.sh $domain $deploy"
  scp ./setup-rails.sh $server:~/
  ssh -t $server "~/setup-rails.sh $domain"
  scp ./setup-nginx.sh $server:~/
  ssh -t $server "~/setup-nginx.sh $domain"
  echo "----------"
  echo "Done!"
  echo "----------"
  echo "NEXT STEPS"
  echo "👉🏼 Hit the API with curl to sanity test if live."
  echo "👉🏼 Manually seed the database with data."
  echo "👉🏼 Set up automated tests and deploys (CI/CD)"
  echo "----------"
fi

if [[ $tech == "Gulp 🍹" ]]; then
  scp ./setup-github.sh $server:~/
  ssh -t $server "~/setup-github.sh $domain"
  scp ./setup-gulp.sh $server:~/
  ssh -t $server "~/setup-gulp.sh $domain"
  scp ./setup-nginx.sh $server:~/
  ssh -t $server "~/setup-nginx.sh $domain"
  echo "----------"
  echo "Done!"
  echo "----------"
  echo "FINAL STEP:"
  echo "👉🏼 Open $domain in your browser. Check whether all is working!"
  sleep 1
  echo "3"
  sleep 1
  echo "2"
  sleep 1
  echo "1"
  sleep 1
  open https://$domain
  echo "----------"
fi

# TODO: reset / wipe project
# rm nginx symbolic link
# rm systemd symbolic link
# sudo rm -rf /var/www/$domain/
# sudo rm -rf /var/log/$domain/
# sudo rm -rf /home/$deploy/.ssh/
# remove deploy user and group entirely
# remove nginx domain name certs

echo "----------"
echo "Project setup complete 🌱"
echo "----------"
