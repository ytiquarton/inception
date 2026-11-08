FROM debian:bullseye

RUN apt-get update && apt-get install -y --no-install-recommends mariadb-server && \
    rm -rf /var/lib/apt/lists/*

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/initial_db.sh /usr/local/bin/initial_db.sh
RUN chmod +x /usr/local/bin/initial_db.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/initial_db.sh"]
