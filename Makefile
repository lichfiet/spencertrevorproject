# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= ./.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "%-30s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# DOCKER TASKS
# Build the container
build: ## Build the container
	@echo "\n...Building Backend Container Image... \n"
	docker build -t $(APP_NAME):dev --platform linux/amd64 -f ./development/Dockerfile . --target=dev
	@echo "\n...Built Backend... \n"

build-nc: ## Build the container without no cache
	docker build -t $(APP_NAME):dev --platform linux/amd64 --no-cache -f ./development/Dockerfile .

run: ## Run container on port configured in `config.env`
	@echo "\n...Launching Dev Server... \n"
	docker run -it --rm -p $(PORT):$(PORT) --name $(APP_NAME) $(APP_NAME):dev
	@echo "\nHold ctrl and click this link 'http://localhost:${PORT}'\n"

run-d: ## Run container on port configured in `config.env`
	@echo "\n...Launching Dev Server... \n"
	docker run -it --rm -p $(PORT):$(PORT) --name $(APP_NAME) -d $(APP_NAME):dev
	@echo "\nHold ctrl and click this link 'http://localhost:${PORT}'\n"

stop:
	@echo "\n...Stopping Docker Container... \n"
	docker stop ${APP_NAME}
	@echo "\n...Docker Container Stopped... \n"

rm:
	@echo "\n...Removing Docker Container... \n"
	docker rm ${APP_NAME}
	@echo "\n...Docker Container Removed... \n"

start-compose: ## Start node and redis in docker compose
	@echo "\n...Launching Dev Server... \n"
	docker compose -f ./docker/compose.yaml up
	@echo "\nHold ctrl and click this link 'http://localhost:8000'\n"

start-compose-d: ## Start node and redis in docker compose
	@echo "\n...Launching Dev Server... \n"
	docker compose -f ./docker/compose.yaml up -d
	@echo "\nHold ctrl and click this link 'http://localhost:8000'\n"

stop-compose: ## stop docker compose
	@echo "\n...Stopping Docker Containers... \n"
	docker compose -f ./docker/compose.yaml down

start-nd: ## Start node not in container
	@echo "\n...Launching Dev Server... \n"
	npm run dev
	@echo "\nHold ctrl and click this link 'http://localhost:8000'\n"



# Clean Up
clean: # Remove images, modules, and cached build layers
	rm -rf node_modules
	-docker stop ${APP_NAME}
	-docker rm ${APP_NAME}
	-docker image rm ${APP_NAME}:dev
	-docker image rm ${APP_NAME}:latest
	-docker rmi $$(docker images -f "dangling=true" -q)

init: # Initailize development environment and start it
	chmod u+x ./development/dev-init.sh
	./development/dev-init.sh
	@echo "\n...Building Web Container Image... \n"
	docker build -t $(APP_NAME):dev --platform linux/amd64 -f ./development/Dockerfile . --target=dev
	@echo "\n...Development Environment Successfully Initialied... \n"
	@echo "\nType 'make help' for a list of commands\n"

build-prod: ## Run for production
	chmod u+x ./development/dev-init.sh
	./development/dev-init.sh
	@echo "\n...Building Web Container Image... \n"
	docker build -t $(APP_NAME):latest --platform linux/amd64 -f ./development/Dockerfile . --target=prod
	@echo "\n...Built Backend... \n"
