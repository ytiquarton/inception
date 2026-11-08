#!/bin/bash

set -e

cd /var/www/html

if [ ! -f "wp-config.php" ]; then
    rm -rf ./* ./.??*
    wp core download --locale=fr_FR --allow-root

    DB_PWD="$(cat /run/secrets/db_password)"
    WP_ADMIN_PWD="$(cat /run/secrets/credentials)"

    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PWD}" \
        --dbhost="mariadb:3306" \
        --allow-root \
        --skip-check

    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception 42" \
        --admin_user="boss_admin" \
        --admin_password="${WP_ADMIN_PWD}" \
        --admin_email="boss@42.fr" \
        --allow-root

    wp user create simple_user simple_user@42.fr \
        --role=subscriber \
        --user_pass="simple_password" \
        --allow-root
fi

exec php-fpm7.4 -F
