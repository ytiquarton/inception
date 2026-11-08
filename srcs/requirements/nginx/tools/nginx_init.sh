#!/bin/bash

set -e

if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=CH/ST=Vaud/L=Lausanne/O=42/OU=42Lausanne/CN=${DOMAIN_NAME}"
fi

envsubst '\$DOMAIN_NAME' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

exec nginx -g 'daemon off;'
