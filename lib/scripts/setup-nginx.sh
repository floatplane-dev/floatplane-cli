#!/bin/bash

set -e

DOMAIN=$1

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
echo "Setting up Nginx..."
echo "----------"
echo "Have you done all of the below? 🥦" 
echo "👉🏼 The A and AAAA records of $DOMAIN are pointing at the IP of server $server."
echo "👉🏼 The code base has nginx/$DOMAIN.conf for HTTPS setup."

wait_until_yes

echo "----------"
echo "Does www.$DOMAIN need to redirect to $DOMAIN? 🪃  (true/false)"
boolean=(true false)
select redirect_www in ${boolean[@]}
do
  if [[ "${boolean[*]}" =~ "${redirect_www}" ]]; then
    break
  else
    echo "Please enter a number from the list."
  fi
done

if [ "$redirect_www" = true ] ; then
  echo "----------"
  echo "Are the A and AAAA records of www.$DOMAIN also pointing at the IP of server $server? 🍉"
  wait_until_yes
fi

# NGINX, CERTBOT, HTTPS CERTIFICATES

echo "----------"
echo "Configuring Nginx for HTTP..."
sudo cat <<EOF > /etc/nginx/sites-available/$DOMAIN.temp.conf
server
{
  listen 80;
  listen [::]:80;
  server_name $DOMAIN;
  root /var/www/$DOMAIN/;
  index index.html;
  location / {
    try_files \$uri /index.html;
  }
}
EOF
sudo ln -nsf /etc/nginx/sites-available/$DOMAIN.temp.conf /etc/nginx/sites-enabled/$DOMAIN.conf
echo "----------"
echo "Testing Nginx configs..."
sudo nginx -t
echo "----------"
echo "Restarting Nginx..."
sudo systemctl restart nginx
echo "----------"
echo "Creating SSL certificates..."
sudo certbot certonly --nginx -d $DOMAIN
if [ "$redirect_www" = true ] ; then
  echo "Creating extra certificate for redirecting www"
  sudo certbot certonly --nginx -d www.$DOMAIN
fi
echo "----------"
echo "Configuring Nginx for HTTPS..."
sudo ln -nsf /var/www/$DOMAIN/nginx/$DOMAIN.conf /etc/nginx/sites-enabled/$DOMAIN.conf
echo "----------"
echo "Removing temporary HTTP config..."
rm -rf /etc/nginx/sites-available/$DOMAIN.temp.conf
echo "----------"
echo "Testing Nginx configs... (again)"
sudo nginx -t
echo "----------"
echo "Restarting Nginx... (again)"
sudo systemctl restart nginx
echo "----------"
echo "Done!"