#/bin/bash

set -e

echo "----------"
echo "Locking down the root user..."
sudo service ssh restart
echo "----------"
echo "Checking SSH status"
sudo service ssh status
echo "----------"
echo "🔥 root user should no longer have access 🔥"
echo "----------"
exit 0;