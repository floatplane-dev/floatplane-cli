#/bin/bash

set -e
set -o pipefail

echo "Setting up server 🗿"
echo "----------"
echo "Have you done the following?"
echo "👉🏼 Created Debian server at Vultr with 2GB of RAM"
echo "👉🏼 Named the server according this pattern:"
echo "    ↳ sydney-server-floatplane-dev"
echo "    ↳ frankfurt-server-interflux-com"
echo "👉🏼 Created A and AAAA pointing to that server with identical name patterns:"
echo "    ↳ sydney.server.floatplane.dev"
echo "    ↳ frankfurt.server.interflux.com"
options=("yes" "no")
select option in "${options[@]}"; do
  [ "$option" ] && break
  echo "Please enter a number from the list."
done
[ "$option" == "no" ] && exit 0
echo "----------"
echo "Enter the domain name (e.g. sydney.server.floatplane.dev):"
read domain
echo "----------"
echo "Enter an SSH alias (e.g. sydney):"
read alias
echo "----------"
ssh_pub_paths=(~/.ssh/*.pub)
ssh_pub_files=("${ssh_pub_paths[@]##*/}")
echo "Which public SSH key should be used?"
select ssh_pub_file in "${ssh_pub_files[@]}"; do
  [ -n "$ssh_pub_file" ] && break
  echo "Please enter a number from the list."
done
ssh_pub_path="${ssh_pub_paths[$((REPLY-1))]}"
echo "ssh_pub_path: $ssh_pub_path"
echo "ssh_pub_file: $ssh_pub_file"
echo "----------"
local_name=$(scutil --get ComputerName)
echo "Configuring SSH on: $local_name"
echo "" >> ~/.ssh/config
echo "" >> ~/.ssh/config
cat <<EOF >> ~/.ssh/config
Host $alias
  User admin
  HostName $domain
  IdentityFile ~/.ssh/$ssh_pub_file
EOF
echo "----------"
echo "Uploading part 1..."
echo "You will need to enter the root password twice."
scp ./setup-server-1.sh root@$domain:/
echo "----------"
echo "Running part 1..."
ssh root@$domain "/setup-server-1.sh"
echo "----------"
echo "Uploading $pub to server..."
# Note: the -f is necessary when there is no private key adjacent to the .pub (we use 1Password)
ssh-copy-id -f -i $ssh_pub_path $alias
echo "----------"
echo "Uploading part 2..."
scp ./setup-server-2.sh $alias:~/
echo "----------"
echo "Running part 2..."
ssh -t $alias "~/setup-server-2.sh"
echo "----------"
echo "Testing if root can still access server..."
echo "Enter the password of the root user 3 times:"
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
scp ./setup-server-3.sh $alias:~/
echo "----------"
echo "Running part 3..."
ssh -t $alias "~/setup-server-3.sh"
echo "----------"
echo "Uploading part 4..."
scp ./setup-server-4.sh $alias:~/
echo "----------"
echo "Running part 4..."
ssh -t $alias "~/setup-server-4.sh"
echo "----------"
echo "Uploading part 5..."
scp ./setup-server-5.sh $alias:~/
echo "----------"
echo "Running part 5..."
ssh -t $alias "~/setup-server-5.sh"
echo "----------"
echo "Server setup complete 🗿"
echo "----------"
echo "NEXT STEPS"
echo ""
echo "Wait 10 seconds, then SSH in with:"
echo "🔑 ssh admin@$domain"
echo "🔑 ssh $alias"
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