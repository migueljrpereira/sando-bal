reset: down build up

soft-reset: down docker-build up

bal-build:
	# cd types && bal build && bal pack && bal push --repository=local
	cd api.sandwich && bal build
	cd api.ingredient && bal build
	cd api.reservation && bal build
	cd api.gateway && bal build

docker-build: 	
	docker-compose build

build: bal-build docker-build

down:
	docker-compose down --remove-orphans --rmi local

up:
	docker-compose up
