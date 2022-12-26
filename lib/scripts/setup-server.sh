#/bin/bash

set -e
set -o pipefail

echo "Setting up server 🗿"
echo "----------"
echo "Have you done all of this?"
echo "👉🏼 Created a Debian server on Vultr"
echo "👉🏼 Decided on a memorable domain name for the server"
echo "👉🏼 Created the A and AAAA records pointing at the server's IP"
options=("yes" "no")
select option in ${options[@]}
do
  if [[ "${options[*]}" =~ "${option}" ]]; then
    # TODO: catch and stop "no"
    break
  else
    echo "Please enter a number from the list."
  fi
done
echo "----------"
echo "Domain name linked to server?"
read domain
echo "----------"
echo "Uploading part 1..."
echo "You will need to enter the root password twice."
scp ./setup-server-1.sh root@$domain:/
echo "----------"
echo "Running part 1..."
ssh root@$domain "/setup-server-1.sh"
echo "----------"
echo "Generating SSH key admin@$domain ..."
private_key=~/.ssh/admin@$domain
public_key=~/.ssh/admin@$domain.pub
rm -rf $private_key
rm -rf $public_key
ssh-keygen -t rsa -b 4096 -C "admin@$domain" -f $private_key
echo "----------"
echo "Addding new SSH key to OpenSSH authentication agent"
ssh-add --apple-use-keychain $private_key
echo "----------"
echo "Configuring SSH to always use this key for this server"
echo "" >> ~/.ssh/config
echo "Host $domain" >> ~/.ssh/config
echo "IdentityFile $private_key" >> ~/.ssh/config
echo "IdentitiesOnly=yes" >> ~/.ssh/config
echo "----------"
echo "Uploading public SSH key to server..."
ssh-copy-id -i $public_key admin@$domain
echo "----------"
echo "Uploading part 2..."
scp ./setup-server-2.sh admin@$domain:~/
echo "----------"
echo "Running part 2..."
ssh -t admin@$domain "~/setup-server-2.sh"
echo "----------"
echo "Testing if root can still access server."
if ! ssh root@$domain "pwd"
then
  echo "Root SSH failed, which is good! 🥳"
else
  echo "Root SSH succeeded... "
  echo "Something went wrong. 🤔"
  echo "Aborting..."
  exit 0;
fi
echo "----------"
echo "Uploading part 3..."
scp ./setup-server-3.sh admin@$domain:~/
echo "----------"
echo "Running part 3..."
ssh -t admin@$domain "~/setup-server-3.sh"
echo "----------"
echo "Uploading part 4..."
scp ./setup-server-4.sh admin@$domain:~/
echo "----------"
echo "Running part 4..."
ssh -t admin@$domain "~/setup-server-4.sh"
echo "----------"
echo "Uploading part 5..."
scp ./setup-server-5.sh admin@$domain:~/
echo "----------"
echo "Running part 5..."
ssh -t admin@$domain "~/setup-server-5.sh"
echo "----------"
echo "Server setup complete 🗿"
echo "----------"
echo "NEXT STEPS"
echo ""
echo "Wait 10 seconds, then SSH in with:"
echo "🔑 ssh admin@$domain"
echo ""
echo "Then verify:"
echo "👉🏼 SSH connection was successful (means Firewall did not lock you out)"
echo "👉🏼 No password should have been asked to connect (means SSH was configured correctly)"
echo "👉🏼 Fish should be your default shell"
echo ""
echo "If all good, you are ready to set up projects! ⛵"
echo ""
echo "fp setup project"
echo "----------"