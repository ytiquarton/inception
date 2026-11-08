#!/bin/bash

set -e

cd /var/www/html

#si wordpress pas encore installe alors on l'initialise
if [ ! -f "wp-config.php" ]; then
	#nettoyer restes
	rm -rf *
	#telecharger code source officiel de wordpress	
	wpcore download --locale=fr_FR --allow-root
	
	DB_PWD=$(cat /run/secrets/db_password)
	WP_ADMIN_PWD=$(cat /run/secrets/credentials)

	#creer le wp-config.php avec les identifiant de base de la db
	wp config create \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${DB_PWD}" \
		--dbhost="mariadb:3306" \
		--allow-root

	#creation admin user pour wordpress
	wp core install \
		--url="${MYSQL_DATABASE}" \
		--title="Inception 42" \
		--admin_user="boss_admin" \
		--admin_password="${WP_ADMIN_PWD}" \
		--admin_email="boss@42.fr" \
		--allow-root

	#creation user pour wordpress 
	wp user create simple_user simple_user@42.fr \
		--role=subscriber \
		--user_pass="simple_password" \
		--allow-root
fi
#remplacer la config PHP-FPM par celle qu'on vient de creer
cp /path/to/your/www.conf /etc/php/7.4/fpm/pool.d/www.conf

#lancer PHP-FPM au premier plan avec -F
exec php-fpm7.4 -F
