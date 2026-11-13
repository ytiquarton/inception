# Developer Documentation

This guide describes how to prepare, build, run, and maintain the Inception
project.

## Prerequisites

On the Linux host, install and start:

- Docker Engine
- Docker Compose plugin (`docker compose`)
- GNU Make

The host must allow Docker to publish port `443`. The Makefile stores persistent
service data under the current user's home directory, so ensure there is
sufficient disk space there.

## Repository layout

```text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        ├── nginx/
        └── wordpress/
```

Each service directory contains its Dockerfile and the service-specific
configuration or initialization scripts. `srcs/docker-compose.yml` builds the
images, connects the services to a private bridge network, mounts persistent
storage, and provides secrets to the containers as files.

## Configure a fresh environment

1. Clone the repository and change to its root directory.
2. Review `srcs/.env`. At minimum, configure `DOMAIN_NAME`; the current Compose
   file sets the database name and user in its service definitions.
3. Create the required secret files before starting Compose:

   | File | Purpose |
   | --- | --- |
   | `secrets/db_root_password.txt` | MariaDB root password |
   | `secrets/db_password.txt` | Password for the WordPress database user |
   | `secrets/credentials.txt` | Initial WordPress administrator password |

   Each file should contain only the intended password and a trailing newline.
   Use strong unique passwords. Restrict local permissions (for example,
   `chmod 600 secrets/*.txt`) and never commit real credentials. File-backed
   Compose secrets are mounted inside containers, but the source files remain
   on the host and are not encrypted at rest.
4. If using a local domain, add a matching entry to the host's `/etc/hosts`,
   pointing the domain in `DOMAIN_NAME` to the appropriate host IP. For local
   testing on the same machine, this is commonly `127.0.0.1`.
5. Check the Compose configuration:

   ```bash
   docker compose -f srcs/docker-compose.yml config
   ```

## Build and launch

From the project root:

```bash
make
```

The `all` target creates `~/data/mariadb` and `~/data/wordpress`, then runs:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

On first startup, MariaDB initializes its database and user, WordPress downloads
and installs WordPress using WP-CLI, and Nginx generates a self-signed TLS
certificate if one is not already present. The site should then be available at
`https://<DOMAIN_NAME>`.

## Container and volume management

| Command | Effect |
| --- | --- |
| `make` / `make all` | Create data directories, build images, and start services |
| `make down` | Stop and remove containers; keep persistent data |
| `make clean` | Run Compose down with volume removal and remove project images |
| `make fclean` | Run `clean`, delete both host data directories, and run `docker system prune -af` |
| `make re` | Run `fclean`, then rebuild and start the stack |

Direct Compose commands:

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f
docker compose -f srcs/docker-compose.yml restart
docker compose -f srcs/docker-compose.yml down
```

`docker compose down` preserves the data directories. `make clean` removes
Compose volumes, and `make fclean` additionally deletes the actual host
directories. **`make fclean` and `make re` are destructive**: they permanently
remove the WordPress files and database in this setup. `docker system prune -af`
may also remove unused images or other unused Docker resources beyond this
project.

## Data locations and persistence

Compose declares two named volumes that use the local driver's bind options:

| Compose volume | Container path | Host path |
| --- | --- | --- |
| `mariadb_volume` | `/var/lib/mysql` | `~/data/mariadb` |
| `wordpress_volume` | `/var/www/html` | `~/data/wordpress` |

The host directories are created by the Makefile. They persist across container
recreation and ordinary `make down` operations. Back them up before cleanup or
rebuild operations that remove volumes or directories.

## Network and exposed ports

The services connect through the Compose bridge network `inception_net` and use
service names (`mariadb`, `wordpress`) to communicate. Only Nginx publishes a
host port: `443:443`. MariaDB and PHP-FPM ports are not published to the host.

## Troubleshooting

- Inspect service state with `docker compose -f srcs/docker-compose.yml ps`.
- Follow logs with `docker compose -f srcs/docker-compose.yml logs -f`.
- Verify that all three secret files exist and that the configured domain is
  consistent with the local DNS or `/etc/hosts` entry.
- Verify that port `443` is not already in use.
- If WordPress or MariaDB has already initialized persistent data, changing a
  secret file will not automatically update an existing database or WordPress
  account password. Update credentials through the relevant service instead.

## Further reading

See the root [README.md](README.md) for the architecture overview, design
comparisons, and external references. See [USER_DOC.md](USER_DOC.md) for
end-user access and credential guidance.
