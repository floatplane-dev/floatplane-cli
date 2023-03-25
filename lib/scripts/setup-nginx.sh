#!/bin/bash

set -e

domain=$1

echo "----------"
echo "Setting up Nginx..."
echo "----------"
echo "Have you done all of the below? 🥦" 
echo "👉🏼 The A and AAAA records of $domain are pointing at the IP of server $server."
echo "👉🏼 The code base has nginx/$domain.conf for HTTPS setup."
echo "👉🏼 The code base has a protected branch called production."
yesno=(yes no)
select answer in ${yesno[@]}
do
  if [ "$answer" == "yes" ]; then
    break
  elif [ "$answer" == "no" ]; then
    echo "Please do so now."
  else
    echo "Please enter a number from the list."
  fi
done
echo "----------"
echo "Does www.$domain need to redirect to $domain? 🪃  (true/false)"
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
  echo "Are the A and AAAA records of www.$domain also pointing at the IP of server $server? 🍉"
  select answer in ${yesno[@]}
  do
    if [ "$answer" == "yes" ]; then
      break
    elif [ "$answer" == "no" ]; then
      echo "Please do so now."
    else
      echo "Please enter a number from the list."
    fi
  done
fi

# NGINX, CERTBOT, HTTPS CERTIFICATES

echo "----------"
echo "Configuring Nginx for HTTP..."
cat <<EOF > /etc/nginx/sites-available/$domain.temp.conf
server
{
  listen 80;
  listen [::]:80;
  server_name $domain;
  root /var/www/$domain/;
  index index.html;
  location / {
    try_files \$uri /index.html;
  }
}
EOF
sudo ln -nsf /etc/nginx/sites-available/$domain.temp.conf /etc/nginx/sites-enabled/$domain.conf
echo "----------"
echo "Testing Nginx configs..."
sudo nginx -t
echo "----------"
echo "Restarting Nginx..."
sudo systemctl restart nginx
echo "----------"
echo "Creating SSL certificates..."
sudo certbot certonly --nginx -d $domain
if [ "$redirect_www" = true ] ; then
  echo "Creating extra certificate for redirecting www"
  sudo certbot certonly --nginx -d www.$domain
fi
echo "----------"
echo "Configuring Nginx for HTTPS..."
sudo ln -nsf /var/www/$domain/nginx/$domain.conf /etc/nginx/sites-enabled/$domain.conf
echo "----------"
echo "Removing temporary HTTP config..."
rm -rf /etc/nginx/sites-available/$domain.temp.conf
echo "----------"
echo "Testing Nginx configs... (again)"
sudo nginx -t
echo "----------"
echo "Restarting Nginx... (again)"
sudo systemctl restart nginx
echo "----------"
echo "Done!"