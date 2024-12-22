ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := compose-help
endif

ifndef MAKESTER__PRIMED
$(info ### Add the following include statement to your Makefile)
$(info include makester/makefiles/makester.mk)
$(error ### missing include dependency)
endif

MAKESTER__DOCKER_COMPOSE ?= $(MAKESTER__DOCKER) compose

MAKESTER__COMPOSE_FILES ?= -f docker-compose.yml

ifndef COMPOSE_CMD
override COMPOSE_CMD = version
endif
MAKESTER__COMPOSE_RUN_CMD ?= SERVICE_NAME=$(MAKESTER__SERVICE_NAME) HASH=$(HASH)\
 $(MAKESTER__DOCKER_COMPOSE)\
 --project-name $(MAKESTER__PROJECT_NAME)\
 $(MAKESTER__COMPOSE_FILES) $(COMPOSE_CMD)

_compose-cmd:
	@$(MAKESTER__COMPOSE_RUN_CMD)

compose-config: COMPOSE_CMD = config

compose-down: COMPOSE_CMD = down -v

compose-ls: COMPOSE_CMD = ls

compose-ps: COMPOSE_CMD = ps

compose-up: COMPOSE_CMD = up -d

compose-config compose-down compose-ls compose-ps compose-up compose-version: _compose-cmd

compose-help:
	printf "\n($(MAKESTER__MAKEFILES)/compose.mk)\n"
	$(call help-line,compose-config,Compose stack \"$(MAKESTER__PROJECT_NAME)\" config ($(MAKESTER__COMPOSE_FILES)))
	$(call help-line,compose-down,Compose stack \"$(MAKESTER__PROJECT_NAME)\" destroy (including volumes))
	$(call help-line,compose-ls,List running compose projects)
	$(call help-line,compose-ps,List running compose containers)
	$(call help-line,compose-up,Compose stack \"$(MAKESTER__PROJECT_NAME)\" create ($(MAKESTER__COMPOSE_FILES)))
	$(call help-line,compose-version,Compose version)

.PHONY: compose-help
