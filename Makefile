all:
	@mkdir -p /home/mclaudet/data/mariadb
	@mkdir -p /home/mclaudet/data/wordpress
	docker-compose -f srcs/docker-compose.yml up -d --build

down:
	docker-compose -f srcs/docker-compose.yml down

clean:
	docker-compose -f srcs/docker-compose.yml down -v --rmi all

fclean: clean
	@sudo rm -rf /home/mclaudet/data/mariadb
	@sudo rm -rf /home/mclaudet/data/wordpress
	docker system prune -af

re: fclean all

.PHONY: all down clean fclean re
