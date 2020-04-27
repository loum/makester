DOCKER_COMPOSE := $(shell which docker-compose 2>/dev/null || echo "3env/bin/docker-compose")
MAKESTER__COMPOSE_FILES ?= -f docker-compose.yml

MAKESTER__COMPOSE_RUN_CMD ?= SERVICE_NAME=$(MAKESTER__PROJECT_NAME) HASH=$(HASH)\
 $(DOCKER_COMPOSE) $(MAKESTER__COMPOSE_FILES) $(COMPOSE_CMD)

compose-cmd:
	@$(MAKESTER__COMPOSE_RUN_CMD)

compose-config: COMPOSE_CMD = config

compose-up: COMPOSE_CMD = up -d

compose-down: COMPOSE_CMD = down -v

compose-config compose-up compose-down: compose-cmd

compose-help:
	@echo "(makefiles/compose.mk)\n\
  compose-config       Compose stack \"$(MAKESTER__PROJECT_NAME)\" config ($(MAKESTER__COMPOSE_FILES))\n\
  compose-up           Compose stack \"$(MAKESTER__PROJECT_NAME)\" create ($(MAKESTER__COMPOSE_FILES))\n\
  compose-down         Compose stack \"$(MAKESTER__PROJECT_NAME)\" destroy (including volumes)\n"

.PHONY: compose-help
