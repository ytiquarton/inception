FROM debian:trixie

RUN apt update && apt upgrade -y && apt install -y mariadb-server && rm -rf /var/lib/apt/lists/*

COPY tools/initial_db.sh /usr/local/bin/initial_db.sh
RUN chmod +x /usr/local/bin/initial_db.sh

EXPOSE 3306

ENTRYPOINT ["initial_db.sh"]
