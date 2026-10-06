#/bin/bash

set -e
set -o pipefail

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

echo "Setting up server 🗿"
echo "----------"
echo "Have you done the following?"
echo "👉🏼 Spun up a server"
echo "    ↳ at Vultr"
echo "    ↳ Debian OS"
echo "    ↳ 2GB RAM minimum"
echo "    ↳ with name like:"
echo "       ↳ floatplane-server-amsterdam"
echo "       ↳ interflux-server-frankfurt"
echo "👉🏼 Created an SSH alias:"
echo "    ~/.ssh/config"
echo "    Host amsterdam"
echo "      User admin"
echo "      HostName 45.32.237.173"
echo "      IdentityFile ~/.ssh/floatplane"

wait_until_yes

echo "----------"
echo "Enter the SSH alias (e.g. melbourne, amsterdam, ...)"
read SSH_HOST
echo "----------"
echo "Enter the IPv4 of the server:"
read IP
echo "----------"
echo "Copy the root user password."
echo "You'll have to enter it multiple times."
echo "Ready?"

wait_until_yes

echo "----------"
echo "PART 1"

scp ./setup-server-1.sh root@$IP:/
ssh root@$IP "/setup-server-1.sh"

echo "----------"

ssh_pub_paths=(~/.ssh/*.pub)
ssh_pub_files=("${ssh_pub_paths[@]##*/}")
echo "Which public SSH key will be used?"
select ssh_pub_file in "${ssh_pub_files[@]}"; do
  [ -n "$ssh_pub_file" ] && break
  echo "Please enter a number from the list."
done
ssh_pub_path="${ssh_pub_paths[$((REPLY-1))]}"
echo "ssh_pub_path: $ssh_pub_path"
echo "ssh_pub_file: $ssh_pub_file"

echo "Uploading $ssh_pub_path to server..."
echo "Enter the $SUDO_USER's password (sudo user)."

# Note: the -f is necessary when there is no private key adjacent to the .pub (we use 1Password)
ssh-copy-id -f -i $ssh_pub_path $SSH_HOST

echo "✅ done"
echo "----------"
echo "PART 2"

scp ./setup-server-2.sh $SSH_HOST:~/
ssh -t $SSH_HOST "~/setup-server-2.sh"

echo "----------"
echo "Next we test if root user can still access server."
echo "Enter the password of the root user 3 times:"

if ! ssh root@$IP "pwd"
then
  echo "✅ Root SSH failed, which is good! 🥳"
else
  echo "❌ Root SSH succeeded... "
  echo "❌ Something went wrong. 🤔"
  echo "❌ Aborting..."
  exit 0;
fi

echo "----------"
echo "PART 3"
scp ./setup-server-3.sh $SSH_HOST:~/
ssh -t $SSH_HOST "~/setup-server-3.sh"
echo "----------"
echo "PART 4"
scp ./setup-server-4.sh $SSH_HOST:~/
ssh -t $SSH_HOST "~/setup-server-4.sh"
echo "----------"
echo "PART 5"
scp ./setup-server-5.sh $SSH_HOST:~/
ssh -t $SSH_HOST "~/setup-server-5.sh"
echo "----------"
echo "Server setup complete 🗿"
echo "----------"
echo "NEXT STEPS"
echo ""
echo "Wait 10 seconds, then SSH in with:"
echo "🔑 ssh $SUDO_USER@$IP"
echo "🔑 ssh $SSH_HOST"
echo ""
echo "Then verify:"
echo "👉🏼 SSH connection was successful (means Firewall did not lock you out)"
echo "👉🏼 No password should have been asked to connect (means SSH was configured correctly)"
echo "👉🏼 Fish should be your default shell"
echo ""
echo "If all good, you are ready to set up apps! ⛵"
echo ""
echo "fp setup app"
echo "----------"