SHELL := /bin/bash
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# all our targets are phony (no files to check).
.PHONY: dev shell root rshell quality tests unit-tests logs

# suppress makes own output
.SILENT:

help:
	@echo ''
	@echo 'Usage: make [TARGET] (example: make dev)'
	@echo 'Targets:'
	@echo '  dev            start docker development environment'
	@echo '  shell          start a new (non-root) shell inside the container'
	@echo '  rshell         start a new (root) shell inside the container'
	@echo '  quality        perform code syntax and quality checks'
	@echo '  tests          perform all unit, function and API tests'
	@echo '  unit-tests     perform all unit tests'
	@echo '  logs          	start printing the logs'
	@echo ''

shell:
	docker exec -it -u nginx web ash

rshell:
	docker exec -it -u root web ash

dev: killenv updateenv startenv

killenv:
	docker stop $$(docker ps -a -q) > /dev/null 2>&1 || true
	docker rm $$(docker ps -a -q) > /dev/null 2>&1 || true

updateenv:
	docker-compose pull

startenv:
	docker-compose up -d
	@echo "Environment has been started!"

.phony: es-index
es-index:
	docker exec -it -u nginx web bin/console app:registration:create-elasticsearch-index

quality:
	@echo "Installing packages to make sure we can run all quality checks"
	composer install --no-scripts --ignore-platform-reqs
	@echo "Updating jakzal/phpqa:1.77-php8.1-alpine docker image"
	docker pull jakzal/phpqa:1.77-php8.1-alpine
	@echo '### Running php-cs-fixer'
	docker run --init -t --rm -v "$(ROOT_DIR):/project" -w /project jakzal/phpqa:1.77-php8.1-alpine php-cs-fixer fix src
	@echo '### Running phpcs'
	docker run --init -t --rm -v "$(ROOT_DIR):/project" -w /project jakzal/phpqa:1.77-php8.1-alpine phpcs -s --standard=phpcs.xml
	@echo '### Running phpmd'
	docker run --init -t --rm -v "$(ROOT_DIR):/project" -w /project jakzal/phpqa:1.77-php8.1-alpine phpmd src ansi phpmd
	@echo '### Running phpcpd'
	docker run --init -t --rm -v "$(ROOT_DIR):/project" -w /project jakzal/phpqa:1.77-php8.1-alpine phpcpd --fuzzy src
	@echo '### Running phpstan'
	docker run --init -t --rm -v "$(ROOT_DIR):/project" -w /project jakzal/phpqa:1.77-php8.1-alpine phpstan -vvv --debug analyze src
	@echo "### Running parallel-lint"
	docker run --init -t --rm -v "$(ROOT_DIR):/project" -w /project jakzal/phpqa:1.77-php8.1-alpine parallel-lint src

tests:
	docker exec -u nginx web make run-tests

setup-pipeline:
	@echo '### Installing dependencies ###'
	curl -o composer.phar https://getcomposer.org/composer-stable.phar
	php -d memory_limit=-1 composer.phar install -v --no-scripts --no-ansi --no-interaction --no-progress
	@echo '### Verifying elasticsearch connection ###'
	sleep 10
	curl -XGET localhost:9200/_cluster/health

run-tests:
	@echo '### Killing potential running PHP server'
	killall php || true
	@echo '### Starting PHP server on localhost:8001'
	APP_ENV=test php -S localhost:8001 -t public & > /dev/null 2>&1
	make api-tests
	make functional-tests
	make unit-tests
	make reports-tests
	@echo '### All tests finished, killing PHP server'
	killall php

api-tests:
	@echo '### Running codeception API tests'
	make clean-test-db
	make fixtures
	APP_ENV=test SYMFONY_DEPRECATIONS_HELPER=weak php vendor/bin/codecept run Api --bootstrap=tests/bootstrap.php

functional-tests:
	@echo '### Running codeception functional tests'
	make clean-test-db
	make fixtures
	APP_ENV=test SYMFONY_DEPRECATIONS_HELPER=weak php vendor/bin/codecept run Functional --bootstrap=tests/bootstrap.php

unit-tests:
	@echo '### Running PHPUnit tests'
	make clean-test-db
	make fixtures
	APP_ENV=test SYMFONY_DEPRECATIONS_HELPER=weak php vendor/bin/codecept run Unit --bootstrap=tests/bootstrap.php

reports-tests:
	@echo '### Running reports tests'
	make clean-test-db
	APP_ENV=test SYMFONY_DEPRECATIONS_HELPER=weak php vendor/bin/codecept run Reports --bootstrap=tests/bootstrap.php

clean-test-db:
	@echo '### Reset test database'
	php bin/console doctrine:database:drop --if-exists --force --env=test
	@echo '### Creating test database'
	php bin/console doctrine:database:create --env=test
	@echo '### Creating Elasticsearch index for registrations'
	php bin/console app:registration:create-elasticsearch-index --no-interaction --env=test
	@echo '### Creating database schema'
	php bin/console doctrine:schema:create --no-interaction --env=test

fixtures:
	@echo '### Creating database fixtures'
	php bin/console doctrine:fixtures:load --no-interaction --env=test
	@echo '### Creating registration fixtures'
	php bin/console app:registration:create-fixture --no-interaction --env=test

logs:
	docker-compose logs -f
