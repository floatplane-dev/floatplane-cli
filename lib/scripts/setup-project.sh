#!/bin/bash

set -e
set -o pipefail

echo "Setting up project 🌱"
echo "----------"
echo "What kind of project?"

options[0]="Ember 🐹"
options[1]="Deno 🦕"
options[2]="Rails 🛤️"
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
servers=(`find ~/.ssh -type f -name "admin@*" -not -name "*.pub" -exec basename {} \; | sort -r | head -2`)
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
while true; do
  read domain
  if [[ -z "$domain" ]]; then
    echo "Please enter a domain name."
  else
    break;
  fi
done


echo "----------"
echo "Have you done all of the below? 🥦" 
echo "👉🏼 The A and AAAA records of $domain are pointing at the IP of server $server."
echo "👉🏼 The code base has nginx/$domain.temp.conf for HTTP setup."
echo "👉🏼 The code base has nginx/$domain.conf for HTTPS setup."
echo "👉🏼 The code base has a protected branch called production."
echo "y/n"

while :
do
read -s -n 1 input
case $input in
  y)
    echo "Yes"
    break;
    ;;
  n)
    echo "No"
    exit 0;
    ;;
esac
done

echo "----------"
echo "Does www.$domain need to redirect to $domain? 🪃  (true/false)"
boolean=(true false)
select redirect_www in ${boolean[@]}
do
  if [[ "${boolean[*]}" =~ "${redirect_www}" ]]; then
    break
  else
    echo "Please enter a number from the list."
  fi
done

echo "----------"
  
if [ "$redirect_www" = true ] ; then
  echo "Are the A and AAAA records of www.$domain also pointing at the IP of server $server?"
  echo "y/n"
  while :
  do
  read -s -n 1 input
  case $input in
    y)
      echo "Yes"
      break;
      ;;
    n)
      echo "No"
      exit 0;
      ;;
  esac
  done
  echo "----------"
fi

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
echo "Connecting to $server ..."
echo "----------"

if [[ $tech == "Ember 🐹" ]]; then
  scp ./setup-project-ember.sh $server:~/
  ssh -t $server "~/setup-project-ember.sh $domain $repo $redirect_www"
fi

if [[ $tech == "Deno 🦕" ]]; then
  scp ./setup-project-deno.sh $server:~/
  ssh -t $server "~/setup-project-deno.sh $domain $repo $redirect_www"
fi

if [[ $tech == "Rails 🛤️" ]]; then
  scp ./setup-project-rauks.sh $server:~/
  ssh -t $server "~/setup-project-rails.sh $domain $repo $redirect_www"
fi

echo "----------"
echo "Project setup complete 🌱"
echo "----------"
