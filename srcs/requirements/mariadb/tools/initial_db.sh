#!/bin/bash

#s'arrête si une commande échoue
set -e

DB_ROOT_PWD="$(cat /run/secrets/db_root_password)"
DB_USER_PWD="$(cat /run/secrets/db_password)"

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

#initialiser la structure de la database
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null 2>&1 || true
fi


if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    #lancer le serveur mariadb en arriere plan avec &
    mysqld --user=mysql --console &
    
    #attendre que le serv soit monté
    until mariadb-admin ping --silent; do
        sleep 1
    done
#setup le serveur (en SQL) 
    mariadb -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PWD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_USER_PWD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    #arreter le server temporairement pour le lancer au premier plan
    mariadb-admin -u root -p"${DB_ROOT_PWD}" shutdown
fi

#lancement au premier plan avec exec
exec mysqld --user=mysql --console
