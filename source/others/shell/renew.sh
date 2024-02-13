#! /bin/bash

# 此脚本用于证书续期

certbot certonly --manual \
-d *.lizec.top \
-d lizec.top --agree-tos \
--manual-public-ip-logging-ok --preferred-challenges \
dns-01 --server https://acme-v02.api.letsencrypt.org/directory

echo "Reload Nginx"
nginx -s reload