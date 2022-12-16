#!/bin/bash

set -e
set -o pipefail

echo "Setting up project 🌱"
echo "----------"

echo "On which Floatplane server do you wish to set up your project? 🚀"
servers=(sydney.floatplane.dev frankfurt.floatplane.dev)
select server in ${servers[@]}
do
  if [[ "${servers[*]}" =~ "${server}" ]]; then
    break
  else
    echo "Please enter a number from the list."
  fi
done
echo "----------"
echo "What's SSH URL of the git repository? 🦑 (git@github.com:floatplane-dev/some-project.git)"
while true; do
  read repo
  if [[ $repo == git@github.com:floatplane-dev/* ]]; then
    break;
  else
    echo "Please enter a URL which starts with git@github.com:floatplane-dev/."
  fi
done
echo "----------"
echo "What's the domain name of the project? ⛵ (foo.com)"
while true; do
  read domain
  if [[ -z "$domain" ]]; then
    echo "Please enter a domain name."
  else
    break;
  fi
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
echo "Setting up $domain on server $server"
echo "----------"
bot='bot'
admin='jw'
(
  set -x
  scp -i ~/.ssh/$bot@$server ./setup-remote-1.sh $bot@$server:~/
  ssh -i ~/.ssh/$bot@$server -t $bot@$server "~/setup-remote-1.sh $domain $repo; rm -f ~/setup-remote-1.sh"
  echo "----------"
  scp ./setup-remote-2.sh $admin@$server:~/
  ssh -t $admin@$server "~/setup-remote-2.sh $domain $redirect_www; rm -f ~/setup-remote-2.sh"
)
