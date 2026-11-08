#!/bin/bash

set -e

#generation du certificat ssl autosigne de 42
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/inception.key \
	-out /etc/nginx/ssl/inception.crt \
	-subj "/C=CH/ST=Vaud/L=Lausanne/O=42/OU=42Lausanne/CN=${DOMAIN_NAME}"
fi

#lancer nginx au pid 1
exec nginx -g "daemon off;"
