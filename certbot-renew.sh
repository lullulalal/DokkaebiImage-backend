#!/bin/bash

# remove "certbot" container
docker rm -f certbot 2>/dev/null

# update let's encrypt certification
docker run --rm --name certbot \
-v '/var/www/DokkaebiImage-backend/certbot/conf:/etc/letsencrypt' \
-v '/var/www/DokkaebiImage-backend/certbot/log:/var/log/letsencrypt' \
-v '/var/www/DokkaebiImage-backend/certbot/www:/var/www/certbot' \
certbot/certbot certonly --webroot -w /var/www/certbot --force-renewal \
--server https://acme-v02.api.letsencrypt.org/directory \
--cert-name 138.199.215.9.nip.io &&

# restart ngins
docker exec nginx nginx -s reload