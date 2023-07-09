bal-build:
	# cd types && bal build && bal pack && bal push --repository=local
	cd api.sandwich && bal build
	cd api.ingredient && bal build
	cd api.reservation && bal build
	cd api.gateway && bal build

docker-build: 	
	docker-compose build

down:
	docker-compose down --remove-orphans --rmi local

up:
	docker-compose up

build: bal-build docker-build

start: build up
soft-start: docker-build up

reset: down start
soft-reset: down soft-start

# DATABASE ONLY DEPLOYMENT
up-db:
	docker-compose -f compose.solodb.yml up

docker-build-db: 	
	docker-compose -f compose.solodb.yml build

down-db:
	docker-compose -f compose.solodb.yml down --remove-orphans --rmi local

build-db: docker-build-db

start-db: build-db up-db
soft-start-db: docker-build-db up-db

reset-db: down-db start-db
soft-reset-db: down-db soft-start-db

switch-to-api: down-db start
switch-to-db: down start-db


