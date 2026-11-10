#!/bin/bash

set -e

DB_ROOT_PWD="$(cat /run/secrets/db_root_password)"
DB_USER_PWD="$(cat /run/secrets/db_password)"

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null 2>&1 || true
fi

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    mysqld --user=mysql --console &

    until mariadb-admin ping --silent; do
        sleep 1
    done

    mariadb -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PWD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_USER_PWD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    mariadb-admin -u root -p"${DB_ROOT_PWD}" shutdown
fi

exec mysqld --user=mysql --console
