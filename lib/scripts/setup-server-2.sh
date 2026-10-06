#/bin/bash

set -e

echo "----------"
echo "✅ server access with sudo user and SSH alias"
echo "----------"
echo "Locking down the root user..."

sudo service ssh restart

echo "✅ done"
echo "----------"
echo "Checking SSH status"

sudo service ssh status

echo "✅ done"
echo "----------"
echo "🔥 root user should no longer have access 🔥"