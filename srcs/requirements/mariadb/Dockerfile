FROM debian:bookworm

#installation de mariadb sans les paquets inutiles
#nettoyer les caches du gestionnaire de paquet
RUN apt-get update && apt-get install -y --no-install-recommends mariadb-server && \
    rm -rf /var/lib/apt/lists/*

#copier le fichier conf dans la conf de mariadb
COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
#copie du script dans le conteneur
COPY tools/initial_db.sh /usr/local/bin/initial_db.sh
RUN chmod +x /usr/local/bin/initial_db.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/initial_db.sh"]

