#!/bin/bash

set -eou pipefail

app_dir="${1:-.}"

if [ ! -f "$app_dir/.fprc" ]; then
  echo "❌ no .fprc found in $app_dir"
  exit 1
fi

source "$app_dir/.fprc"

echo "----------"
echo "⛵️ deploying ..."
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

scp ./deploy-$TECH.sh $SSH_HOST:~/
echo "----------"
echo "✅ scp"
echo "----------"
ssh -t $SSH_HOST "~/deploy-$TECH.sh $DOMAIN"
echo "----------"
echo "✅ deploy complete"
echo "----------"