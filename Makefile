# Project Variables
PROJECT_NAME ?= todobackend
ORG_NAME ?= alexkoepke
REPO_NAME ?= todobackend

# Filenames
DEV_COMPOSE_FILE := docker/dev/docker-compose.yml
REL_COMPOSE_FILE := docker/release/docker-compose.yml

# Docker COmpose Project Names
REL_PROJECT := $(PROJECT_NAME)$(BUILD_ID)
DEV_PROJECT := $(REL_PROJECT)dev


.PHONY: test build release clean

test:
	${INFO} "Building images..."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) build
	${INFO} "Building agent"
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) up agent
	${INFO} "Building Test"
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) up test
	@ docker cp $$(docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) ps -q test):/reports/. reports
	${INFO} "Make Test Complete"

build:
	${INFO} "make build start"
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) up builder
	${INFO} "Copying application artifacts..."
	@ docker cp $$(docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) ps -q builder):/wheelhouse/. target
	${INFO} "make build finish"

release:
	${INFO} "make release start"
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) build
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) up agent
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) run --rm app manage.py collectstatic --noinput
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) run --rm app manage.py migrate --noinput
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) up test
	@ docker cp $$(docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) ps -q test):/reports/. reports
	open "http://localhost:8000/"
	${INFO} "make release finish"

clean:
	${INFO} "Destroying development environment..."
	@ docker-compose -p $(REL_PROJECT) -f $(DEV_COMPOSE_FILE) kill
	@ docker-compose -p $(REL_PROJECT) -f $(DEV_COMPOSE_FILE) rm -f -v
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) kill
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) rm -f -v
	@ docker images -q -f dangling=true -f label=application=$(REPO_NAME) | xargs -I ARGS docker rmi -f ARGS
	${INFO} "Clean Complete"

# Cosmetics
YELLOW := "\e[1;33m"
NC := "\e[0m"

# Shell Functions
INFO := @bash -c '\
	printf $(YELLOW); \
	echo "=> $$1"; \
	printf $(NC)' VALUE