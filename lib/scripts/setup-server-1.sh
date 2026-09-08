#/bin/bash

set -e

SUDO_USER=admin

echo "----------"
echo "Great, we're on the server."
echo "----------"
echo "Creating sudo user ..."
useradd --create-home --groups sudo $SUDO_USER
passwd $SUDO_USER
echo "----------"
echo "Configuring SSH"
cd /etc/ssh
sed -e "s/PermitRootLogin yes/PermitRootLogin no/g" -e "s/PasswordAuthentication yes/PasswordAuthentication no/g" sshd_config > temporary
mv temporary sshd_config
echo "----------"
echo "Silencing the login message ..."
touch /home/$SUDO_USER/.hushlogin
echo "----------"
exit 0;