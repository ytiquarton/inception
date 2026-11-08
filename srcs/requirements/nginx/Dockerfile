FROM debian:bullseye

#maj et installationde nginx et openssl
RUN apt update && apt upgrade -y && \
	apt install -y nginx openssl && \
	rm -rf /var/lib/apt/lists/*

#dossier pour stocker certificat ssl
RUN mkdir -p /etc/nginx/ssl

#copie du script de config et execution
COPY tools/nginx_init.sh /usr/local/bin/nginx_init.sh
RUN chmod +x /usr/local/bin/nginx_init.sh

#exposer le port https
EXPOSE 443

#lancer ngingx au premier plan
ENTRYPOINT ["nginx_init.sh"]
