#!/bin/bash

#arrete le script si une commande échoue
set -e

# aller dans le dossier wordpress
cd /var/www/html

#fait la config de wp si elle existe pas
if [ ! -f "wp-config.php" ]; then
    #nettoyage des residus s'il y en a
    rm -rf ./* ./.??*
    
    #telecharger worpress en français en tant que root
    wp core download --locale=fr_FR --allow-root

    DB_PWD="$(cat /run/secrets/db_password)"

    #config pour la database
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PWD}" \
        --dbhost="mariadb:3306" \
        --allow-root \
        --skip-check
fi

#check temporel pour voir si la database est up
for _ in $(seq 1 30); do
    if wp db check --allow-root --path=/var/www/html >/dev/null 2>&1; then
        break
    fi
    sleep 2
done

#check pour voir si le mdp contient un admin
WP_ADMIN_PWD="$(cat /run/secrets/credentials)"

    if echo "${WP_ADMIN_PWD}" | grep -qi "admin" ; then
        echo "WP_ADMIN_PWD can't contain 'admin'"
        exit 1
    fi
#config de wordpress
if ! wp core is-installed --allow-root --path=/var/www/html >/dev/null 2>&1; then
    
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception 42" \
        --admin_user="boss" \
        --admin_password="${WP_ADMIN_PWD}" \
        --admin_email="boss@42.fr" \
        --allow-root

    if ! wp user get simple_user --allow-root --path=/var/www/html >/dev/null 2>&1; then
        wp user create simple_user simple_user@42.fr \
            --role=subscriber \
            --user_pass="${SIMPLE_USER_PWD}" \
            --allow-root
    fi
fi

#mettre wordpress au premier plan du container
exec php-fpm8.2 -F
