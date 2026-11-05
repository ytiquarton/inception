#!/bin/bash

set -e

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then

	mysqld & 

	until mysqladmin ping --silent; do
		sleep 1
	done

	DB_ROOT_PWD=$(cat /run/secrets/db_root_password)
	DB_USER_PWD=$(cat /run/secrets/db_password)

	mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PWD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_USER_PWD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

	mysqladmin -u root -p "${DB_ROOT_PWD}" shutdown
fi

exec mysqld
