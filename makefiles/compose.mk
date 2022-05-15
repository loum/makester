ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := compose-help
endif

# Look for podman. Falls through to docker.
_DOCKER := $(shell which podman 2>/dev/null)
ifndef _DOCKER
_DOCKER := $(shell which docker 2>/dev/null)
endif
$(call check_defined, _DOCKER, can't find a container compose spec: docker and podman supported)
DOCKER_COMPOSE := $(shell which $(_DOCKER)-compose 2>/dev/null || echo "3env/bin/$(shell basename $(_DOCKER))-compose")

MAKESTER__COMPOSE_FILES ?= -f docker-compose.yml

MAKESTER__COMPOSE_RUN_CMD ?= SERVICE_NAME=$(MAKESTER__SERVICE_NAME) HASH=$(HASH)\
 $(DOCKER_COMPOSE)\
 --project-name $(MAKESTER__PROJECT_NAME)\
 $(MAKESTER__COMPOSE_FILES) $(COMPOSE_CMD)

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
