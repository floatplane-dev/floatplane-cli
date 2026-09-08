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
echo "SERVER=$SERVER"
echo "DOMAIN=$DOMAIN"
echo "TECH=$TECH"
echo "----------"

if [ "$SERVER" != "melbourne" ] && [ "$TECH" != "amsterdam" ]; then
  echo "❌ unsupported SERVER: $SERVER"
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

scp ./deploy-$TECH.sh $SERVER:~/
echo "----------"
echo "✅ scp"
echo "----------"
ssh -t $SERVER "~/deploy-$TECH.sh $DOMAIN"
echo "----------"
echo "✅ deploy complete"
echo "----------"