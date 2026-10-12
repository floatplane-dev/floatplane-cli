#!/bin/bash

set -eou pipefail

DEPLOY_USER=bot

echo "----------"
echo "sync data 👯‍♀️"

APP_DIR="${1:-.}"

if [ ! -f "$APP_DIR/.fprc" ]; then
  echo "----------"
  echo "❌ no .fprc found in $APP_DIR"
  exit 1
fi

cd "$APP_DIR"

source .fprc

if [ "$SSH_HOST" != "melbourne" ] && [ "$SSH_HOST" != "amsterdam" ]; then
  echo "----------"
  echo "❌ unsupported SSH_HOST: $SSH_HOST"
  exit 1
fi

if [ "$TECH" != "rails" ]; then
  echo "----------"
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
echo "You are about synchronise the development database with production."
echo "Go ahead and DROP the development database? ⚠️"

wait_until_yes

TIMESTAMP="$(date -u +"%Y-%m-%d-%H%M%S")-UTC"
DB_NAME_PROD="$(RAILS_ENV=production bin/rails runner 'puts ActiveRecord::Base.connection_db_config.database')"
DB_NAME_DEV="$(RAILS_ENV=development bin/rails runner 'puts ActiveRecord::Base.connection_db_config.database')"
FILE_NAME="$DB_NAME_PROD-$TIMESTAMP.dump"

echo "----------"
echo "SSH_HOST: $SSH_HOST"
echo "DOMAIN: $DOMAIN"
echo "TECH: $TECH"
echo "DB_NAME_DEV: $DB_NAME_DEV"
echo "DB_NAME_PROD: $DB_NAME_PROD"
echo "TIMESTAMP: $TIMESTAMP"
echo "FILE_NAME: $FILE_NAME"
echo "----------"
echo "Does the above look correct?"

wait_until_yes

echo "----------"
if ! ssh $SSH_HOST "psql -d postgres -tAc \"SELECT 1 FROM pg_roles WHERE rolname='admin'\"" | grep -q 1; then
  echo "❌ Postgres user admin does not exist on $SSH_HOST"
  echo "Run: sudo -u postgres createuser -s admin"
  exit 1
fi

echo "----------"
(
  set -x
  mkdir -p db/dumps
  ssh $SSH_HOST "pg_dump -Fc --no-owner --no-privileges --verbose $DB_NAME_PROD" > db/dumps/$FILE_NAME
  ls -la db/dumps
)

echo "✅ Downloaded production database"
echo "----------"

(
  set -x
  RAILS_ENV=development DISABLE_DATABASE_ENVIRONMENT_CHECK=1 rails db:drop db:create
)

echo "✅ Dropped local database"
echo "----------"

(
  set -x
  pg_restore --clean --if-exists --no-owner --no-privileges --dbname=$DB_NAME_DEV db/dumps/$FILE_NAME
)

echo "----------"
echo "✅ Synced local database with production"
echo "----------"

# In case:
# PG::ObjectInUse: ERROR:  database "interflux_development" is being accessed by other users
# Use:
# psql -d postgres -c "SELECT pid, usename, application_name, client_addr FROM pg_stat_activity WHERE datname = 'interflux_development';"
# Then:
# kill -9 <PID>