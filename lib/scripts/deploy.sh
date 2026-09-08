#!/bin/bash

set -eou pipefail

APP_DIR="${1:-.}"

if [ ! -f "$APP_DIR/.fprc" ]; then
  echo "❌ no .fprc found in $APP_DIR"
  exit 1
fi

source "$APP_DIR/.fprc"

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