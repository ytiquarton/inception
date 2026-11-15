MARIADB_DIR = /home/mclaudet/data/mariadb
WORDPRESS_DIR = /home/mclaudet/data/wordpress
COMPOSE_FILE = srcs/docker-compose.yml
DOCKER_COMPOSE = docker compose

SITE = https://mclaudet.42.fr

all:
	mkdir -p $(MARIADB_DIR) $(WORDPRESS_DIR)
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d --build
	@echo "localhost link  $(SITE)"

down:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down

clean:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down -v --rmi all

fclean: clean
	sudo rm -rf $(MARIADB_DIR) $(WORDPRESS_DIR)
	docker system prune -af

re: fclean all

.PHONY: all down clean fclean re
