DOCKER := $(shell which docker 2>/dev/null)

MAKESTER__CONTAINER_NAME ?= my-container
MAKESTER__IMAGE_TAG ?= latest
MAKESTER__RUN_COMMAND ?= $(DOCKER) run --rm\
 --name $(MAKESTER__CONTAINER_NAME)\
 $(MAKESTER__SERVICE_NAME):$(HASH)

run:
	@$(MAKESTER__RUN_COMMAND) || true

stop:
	@$(DOCKER) stop $(MAKESTER__CONTAINER_NAME) || true

RUNNING_CONTAINER := $(shell docker ps | grep $(MAKESTER__CONTAINER_NAME) | rev | cut -d' ' -f 1 | rev)
status:
ifneq ($(RUNNING_CONTAINER),)
	@echo \"$(MAKESTER__CONTAINER_NAME)\" Docker container is running.  Run \"make stop\" to terminate
else
	@echo \"$(MAKESTER__CONTAINER_NAME)\" Docker container not running. Run \"make run\" to start
endif

IMAGE_TAG := $(shell $(DOCKER) images --filter=reference=$(MAKESTER__SERVICE_NAME) --format "{{.ID}}" | head -1)
$(warning IMAGE_TAG: $(IMAGE_TAG))
$(warning MAKESTER__SERVICE_NAME: $(MAKESTER__SERVICE_NAME))
$(warning MAKESTER__IMAGE_TAG: $(MAKESTER__IMAGE_TAG))
tag:
	@$(DOCKER) tag $(IMAGE_TAG) $(MAKESTER__SERVICE_NAME):$(MAKESTER__IMAGE_TAG)

rm-dangling-images:
	$(shell $(DOCKER) rmi $($(DOCKER) images -q -f dangling=true`))

docker-help:
	@echo "(makefiles/docker.mk)\n\
  run:                 Run image $(MAKESTER__SERVICE_NAME):$(HASH) as $(MAKESTER__CONTAINER_NAME)\n\
  stop:                Stop container $(MAKESTER__CONTAINER_NAME)\n\
  status:              Check container $(MAKESTER__CONTAINER_NAME) status\n\
  tag:                 Tag image $(MAKESTER__SERVICE_NAME):latest (default)\n\
  rm-dangling-images:  Remove all dangling images\n\
	";

.PHONY: docker-help
