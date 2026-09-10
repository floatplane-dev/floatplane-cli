#!/bin/bash

set -eou pipefail

APP_DIR="${1:-.}"

if [ ! -f "$APP_DIR/.fprc" ]; then
  echo "❌ no .fprc found in $APP_DIR"
  exit 1
fi

source "$APP_DIR/.fprc"

echo "----------"
echo "❤️‍🔥 removing app ..."
echo "----------"
echo "SSH_HOST=$SSH_HOST"
echo "DOMAIN=$DOMAIN"
echo "TECH=$TECH"
echo "----------"


if [ "$SSH_HOST" != "melbourne" ] && [ "$SSH_HOST" != "amsterdam" ]; then
  echo "❌ unsupported SSH_HOST: $SSH_HOST"
  exit 1
fi

if [ -z "$DOMAIN" ]; then
  echo "❌ no DOMAIN"
  exit 1
fi

if [ "$TECH" != "svelte" ] && [ "$TECH" != "rails" ]; then
  echo "❌ unsupported TECH: $TECH"
  exit 1
fi

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
echo "Are you certain?"

wait_until_yes

if [ "$TECH" != "rails" ]; then
    scp ./remove-app-rails.sh $SSH_HOST:~/
    ssh -t $SSH_HOST "~/remove-app-rails.sh $DOMAIN"
fi