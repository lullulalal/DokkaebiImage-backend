#!/bin/bash

domains=(138.199.215.9.nip.io)
email="your@email.com"
data_path="./docker/certbot"
rsa_key_size=4096
staging=0

if [ -d "$data_path" ]; then
  read -p "Existing data found. Replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ]; then
    exit
  fi
fi

mkdir -p "$data_path/www" "$data_path/conf" "$data_path/log"

docker-compose run --rm --entrypoint "\
  certbot certonly --webroot \
  --webroot-path=/var/www/certbot \
  --email $email \
  --agree-tos \
  --no-eff-email \
  -d ${domains[@]}" certbot
