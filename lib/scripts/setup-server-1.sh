#/bin/bash

set -e

SUDO_USER=admin

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
echo "✅ server access with root user"
echo "----------"
echo "We're about to create a sudo user called $SUDO_USER to replace root."
echo "First, create a long random password in 1Password."
echo "Ready?"

wait_until_yes

useradd --create-home --groups sudo $SUDO_USER
passwd $SUDO_USER

echo "✅ done"
echo "----------"
echo "Configuring SSH"

cd /etc/ssh
sed -e "s/PermitRootLogin yes/PermitRootLogin no/g" -e "s/PasswordAuthentication yes/PasswordAuthentication no/g" sshd_config > temporary
mv temporary sshd_config

echo "✅ done"
echo "----------"
echo "Silencing the login message ..."

touch /home/$SUDO_USER/.hushlogin

echo "✅ done"