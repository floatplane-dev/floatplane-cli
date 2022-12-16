#/bin/bash

set -e

echo "----------"
echo "Great, we're on the server."
echo "----------"
echo "Creating admin user ..."
useradd --create-home --groups sudo admin
passwd admin
echo "----------"
echo "Configuring SSH"
cd /etc/ssh
sed -e "s/PermitRootLogin yes/PermitRootLogin no/g" -e "s/PasswordAuthentication yes/PasswordAuthentication no/g" sshd_config > temporary
mv temporary sshd_config
echo "----------"
echo "Silencing the login message ..."
touch /home/admin/.hushlogin
echo "----------"
exit 0;