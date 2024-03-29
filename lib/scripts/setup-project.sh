#!/bin/bash

set -eou pipefail

echo "Setting up project 🌱"
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
echo "On which server? 🚀"

# Here we grab all the private SSH keys from ~/.ssh which start with admin@ (assuming these are all servers set up with FP CLI)
servers=(`find ~/.ssh -type f -name "admin@*" -not -name "*.pub" -exec basename {} \; | sort -r`)
select server in ${servers[@]}
do
  if [[ "${servers[*]}" =~ "${server}" ]]; then
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
  echo "Does your Rails codebase meet these criteria?"
  echo "✅ It has .ruby-version"
  echo "✅ It has .rbenv-vars.example"
  echo "✅ It has config/credentials.yml.enc"
  echo "✅ It does not have config/master.key"
  yesno=(yes no)
  select answer in ${yesno[@]}
  do
    if [ "$answer" == "yes" ]; then
      break
    elif [ "$answer" == "no" ]; then
      echo "Please do so now and git push."
    else
      echo "Please enter a number from the list."
    fi
  done
  scp ./setup-github.sh $server:~/
  ssh -t $server "~/setup-github.sh $domain"
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

echo "----------"
echo "Project setup complete 🌱"
echo "----------"
