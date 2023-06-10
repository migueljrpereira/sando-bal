reset: down build up

build:
	# cd types && bal build && bal pack && bal push --repository=local
	cd api.sandwich && bal build
	cd api.ingredient && bal build
	docker-compose build

down:
	docker-compose down --remove-orphans --rmi local

up:
	docker-compose up
