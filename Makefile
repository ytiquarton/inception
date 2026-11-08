all:
	@mkdir -p $(MARIADB_DIR) $(WORDPRESS_DIR)
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d --build

down:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down

clean:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down -v --rmi all

fclean: clean
	@rm -rf $(MARIADB_DIR) $(WORDPRESS_DIR)
	docker system prune -af

re: fclean all

.PHONY: all down clean fclean re
