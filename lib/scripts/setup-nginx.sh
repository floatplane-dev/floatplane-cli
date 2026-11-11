#!/bin/bash

set -e

DOMAIN=$1
CA=$2
REDIRECT_WWW=$3

if [ "$CA" = "Let's Encrypt" ] ; then
  echo "----------"
  echo "Setting up Nginx with Let's Encrypt"
  echo "----------"
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
  echo "✅ created temporary HTTP Nginx config."
  echo "----------"
  sudo ln -nsf /etc/nginx/sites-available/$DOMAIN.temp.conf /etc/nginx/sites-enabled/$DOMAIN.conf
  echo "✅ created symbolic link to temporary Nginx config"
  echo "----------"
  sudo nginx -t
  echo "✅ passed Nginx test"
  echo "----------"
  sudo systemctl restart nginx
  sudo systemctl status nginx --no-pager
  echo "✅ restarted Nginx service"
  echo "----------"
  echo "Creating TLS certificates..."
  sudo certbot certonly --nginx -d $DOMAIN
  echo "✅ created TLS certificate at Let's Encrypt for apex domain"
  echo "----------"
  if [ "$REDIRECT_WWW" = true ] ; then
    sudo certbot certonly --nginx -d www.$DOMAIN
    echo "✅ created TLS certificate at Let's Encrypt for www domain"
    echo "----------"
  fi
  echo "----------"
  echo "Removing temporary HTTP config..."
  rm -rf /etc/nginx/sites-available/$DOMAIN.temp.conf
  echo "✅ removed temporary Nginx config"
  echo "----------"
fi

if [ "$CA" = "Cloudflare" ] ; then
  echo "----------"
  echo "Setting up Nginx with Cloudflare"
  echo "----------"
  echo "TODO 👋"
  echo "1. Go to Cloudflare → SSL/TLS → Origin Server → Create Certificate"
  echo "2. Create certificate with:"
  echo "   ↳ Type: RSA"
  echo "   ↳ Hostnames: *.foo.com and foo.com"
  echo "   ↳ Validity: 15 years"
  echo "   ↳ Format: PEM"
  echo "3. Copy the Origin Certificate and paste below:"

  CF_CERT=""
  while IFS= read -rs line; do
    CF_CERT+="$line"$'\n'
    [[ "$line" == *"END CERTIFICATE"* ]] && break
  done

  echo "4. Copy the Private Key and paste below:"

  CF_KEY=""
  while IFS= read -rs line; do
    CF_KEY+="$line"$'\n'
    [[ "$line" == *"END"* && "$line" == *"KEY"* ]] && break
  done
  echo

  echo "----------"
  if [[ -d /etc/ssl/cloudflare ]]; then
    echo "✅ /etc/ssl/cloudflare already exists"
  else
    sudo mkdir -p /etc/ssl/cloudflare
    echo "✅ created /etc/ssl/cloudflare"
  fi
  echo "----------"
  sudo tee /etc/ssl/cloudflare/$DOMAIN.pem > /dev/null <<EOF
$CF_CERT
EOF
  echo "✅ created Cloudflare certificate"
  echo "----------"
  sudo tee /etc/ssl/cloudflare/$DOMAIN.key > /dev/null <<EOF
$CF_KEY
EOF
  echo "✅ created Cloudflare private key"
  echo "----------"
  sudo chmod 644 /etc/ssl/cloudflare/$DOMAIN.pem
  sudo chmod 600 /etc/ssl/cloudflare/$DOMAIN.key
  sudo chown root:root /etc/ssl/cloudflare/*
  echo "✅ Set permissions"
fi

echo "----------"
sudo ln -nsf /var/www/$DOMAIN/nginx/$DOMAIN.conf /etc/nginx/sites-enabled/$DOMAIN.conf
echo "✅ created symbolic link to final Nginx config"
echo "----------"
sudo nginx -t
echo "✅ passed Nginx test"
echo "----------"
sudo systemctl restart nginx
sudo systemctl status nginx --no-pager
echo "✅ restarted Nginx"
echo "----------"
echo "Done!"