#!/bin/bash

#arrte le script si une commande échoue
set -e

#verification du certificat ssl et generation si inexistant
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=CH/ST=Vaud/L=Lausanne/O=42/OU=42Lausanne/CN=${DOMAIN_NAME}"
        #-x509 = option pour demander un certificat autosigné
        # -nodes (No DES) ne pas chiffrer la clé avec un mdp
        # -keyout/-out fichier de sortie de la clé rsa et du certificat
        # -subj infos d'identité du certificat
fi

#on injecte le nom du domaine dans la config nginx (nginx ne sais pas le faire)
envsubst '\$DOMAIN_NAME' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

#lancement de nginx
exec nginx -g 'daemon off;'
