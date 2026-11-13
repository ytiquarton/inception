*This project has been created as part of the 42 curriculum by mclaudet*

# Inception

## Description

Inception is a 42 project that introduces containerization by deploying a small
WordPress website with Docker Compose. Its goal is to run the web server, the
WordPress application, and the database in separate services built from their
own Dockerfiles.

The stack provides:

- **Nginx** as the HTTPS entry point and reverse proxy, listening on host port
  `443`.
- **WordPress** served by PHP-FPM 8.2 and installed/configured with WP-CLI.
- **MariaDB** as the database server for WordPress.

The containers share a private Docker bridge network. Nginx and WordPress share
the WordPress files; MariaDB stores its database separately. Persistent data is
kept in `~/data/wordpress` and `~/data/mariadb` on the host. Nginx generates a
self-signed TLS certificate on first start, so browsers warn that the
certificate is not trusted.

### Docker and design choices

Docker packages each service and its runtime dependencies into an isolated
container. The source files included in this repository define how those
containers are built and configured:

- `srcs/requirements/nginx/`: Nginx image, HTTPS virtual host configuration,
  certificate initialization script.
- `srcs/requirements/wordpress/`: WordPress/PHP-FPM image, PHP-FPM pool
  configuration, and first-run WordPress setup script.
- `srcs/requirements/mariadb/`: MariaDB image, server configuration, and
  database initialization script.
- `srcs/docker-compose.yml`: services, network, persistent storage, environment
  settings, and secret-file mounts.
- `srcs/.env`, `secrets/`, and `Makefile`: domain/database settings, credentials,
  and project lifecycle commands.

The main design choices and alternatives are:

| Topic | Choice in this project | Alternative and trade-off |
| --- | --- | --- |
| Virtual machines vs Docker | Docker containers share the host kernel and isolate individual services. They are lightweight and quick to build/start. | A virtual machine runs a full guest OS and kernel, usually providing stronger OS-level isolation but using more resources and taking longer to start. |
| Secrets vs environment variables | Passwords are supplied to containers as Compose secrets mounted as files under `/run/secrets`; non-secret settings such as the domain and database name are environment variables. | Environment variables are convenient for ordinary configuration but can be exposed through process/container inspection and are easy to log accidentally. Local Compose file-backed secrets limit how passwords are passed to the application, but do not encrypt the source files at rest; protect those files and the host. |
| Docker network vs host network | Services use a private bridge network; only Nginx publishes port `443` to the host. Services address each other by Compose service name. | Host networking removes network isolation and shares the host network namespace. It may be simpler in some cases, but exposes services more directly and can cause port conflicts. |
| Docker volumes vs bind mounts | Compose declares named volumes for MariaDB and WordPress, using the local volume driver's bind options to store their data in `~/data/mariadb` and `~/data/wordpress`. | A Docker-managed volume is stored and managed by Docker in its own data area. A direct bind mount points to a specific host path and is easy to inspect or back up, but depends on that path and host permissions. This project uses named-volume declarations backed by host directories. |

## Instructions

### Requirements

- Linux host with Docker Engine running
- Docker Compose plugin (`docker compose`)
- GNU Make
- Host port `443` available

### Configure and run

1. Set `DOMAIN_NAME` in `srcs/.env`. The checked-in example uses
   `mclaudet.42.fr`.
2. Ensure these files exist and contain the corresponding passwords, one per
   file:
   - `secrets/db_root_password.txt`: MariaDB root password
   - `secrets/db_password.txt`: WordPress database user's password
   - `secrets/credentials.txt`: WordPress administrator password, used during
     initial installation
3. For local access, map the configured domain to the host in `/etc/hosts`, for
   example:

   ```text
   127.0.0.1 mclaudet.42.fr
   ```

4. From the repository root, build and start the stack:

   ```bash
   make
   ```

5. Open `https://<DOMAIN_NAME>` in a browser. The browser will report a
   certificate warning because the generated certificate is self-signed.

Useful Make targets:

| Command | Action |
| --- | --- |
| `make` or `make all` | Create host data directories, build images, and start the services |
| `make down` | Stop and remove containers while retaining persistent data |
| `make clean` | Stop containers and remove Compose volumes and project images |
| `make fclean` | Run `clean`, remove the host data directories, and prune Docker resources |
| `make re` | Run `fclean`, then build and start the project again |

**Warning:** `make fclean` and `make re` delete the local WordPress and MariaDB
data. `make fclean` also runs `docker system prune -af`, which can remove
unrelated unused Docker resources on the host.

To run Compose commands directly, use:

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs
docker compose -f srcs/docker-compose.yml down
```

## Resources

### Documentation and references

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Docker storage documentation](https://docs.docker.com/engine/storage/)
- [Docker networking documentation](https://docs.docker.com/engine/network/)
- [Docker secrets documentation](https://docs.docker.com/compose/how-tos/use-secrets/)
- [WordPress documentation](https://wordpress.org/documentation/)
- [WP-CLI documentation](https://make.wordpress.org/cli/handbook/)
- [Nginx documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)

### AI usage

AI assistance was used to draft and organize the project documentation:
the root README, the end-user guide, and the developer guide. It helped explain
the existing Docker Compose configuration, summarize the Makefile commands, and
describe the requested Docker design comparisons. The documentation was checked
against the repository's configuration files and startup scripts. AI was not
used to implement the application or container code.

## Further documentation

- [USER_DOC.md](USER_DOC.md) — end-user and administrator instructions
- [DEV_DOC.md](DEV_DOC.md) — environment setup, build, container management, and
  persistence details
