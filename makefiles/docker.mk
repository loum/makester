DOCKER := $(shell which docker 2>/dev/null)

MAKESTER__CONTAINER_NAME ?= my-container
MAKESTER__RUN_COMMAND ?= $(DOCKER) run --rm\
 --name $(MAKESTER__CONTAINER_NAME)\
 $(MAKESTER__SERVICE_NAME):$(HASH)

run:
	@$(MAKESTER__RUN_COMMAND) || true

stop:
	@$(DOCKER) stop $(MAKESTER__CONTAINER_NAME) || true

RUNNING_CONTAINER = $(shell $(DOCKER) ps | grep $(MAKESTER__CONTAINER_NAME))
status:
ifneq ($(RUNNING_CONTAINER),)
	@echo \"$(MAKESTER__CONTAINER_NAME)\" Docker container is running.  Run \"make stop\" to terminate
else
	@echo \"$(MAKESTER__CONTAINER_NAME)\" Docker container not running. Run \"make run\" to start
endif

rm-dangling-images:
	$(shell $(DOCKER) rmi $($(DOCKER) images -q -f dangling=true`))

docker-help:
	@echo "(makefiles/docker.mk)\n\
  run:                 Run image $(MAKESTER__SERVICE_NAME):$(HASH) as $(MAKESTER__CONTAINER_NAME)\n\
  stop:                Stop container $(MAKESTER__CONTAINER_NAME)\n\
  status:              Check container $(MAKESTER__CONTAINER_NAME) status\n\
  rm-dangling-images:  Remove all dangling images\n\
	";

.PHONY: docker-help
