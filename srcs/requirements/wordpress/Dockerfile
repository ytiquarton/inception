FROM debian:bullseye

RUN apt update && apt upgrade -y && \
	apt install -y php7.4-fpm php7.4-mysql curl mariadb-client &&
	rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /run/php

COPY tools/wp_setup.sh /usr/local/bin/wp_setup.sh
RUN chmod +x /usr/local/bin/wp_setup.sh

EXPOSE 9000

ENTRYPOINT ["wp_setup.sh"]
