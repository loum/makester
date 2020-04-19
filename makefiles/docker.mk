DOCKER := $(shell which docker 2>/dev/null)

MAKESTER__CONTAINER_NAME = my-container
MAKESTER__IMAGE_TAG = latest

# MAKESTER__SERVICE_NAME supports optional MAKESTER__REPO_NAME.
ifdef MAKESTER__REPO_NAME
MAKESTER__SERVICE_NAME = $(MAKESTER__REPO_NAME)/$(MAKESTER__PROJECT_NAME)
else
MAKESTER__SERVICE_NAME = $(MAKESTER__PROJECT_NAME)
endif

# Can be overriden in user Makefile.
MAKESTER__RUN_COMMAND = $(DOCKER) run --rm\
 --name $(MAKESTER__CONTAINER_NAME)\
 $(MAKESTER__SERVICE_NAME):$(HASH)

# Can be overriden in user Makefile.
MAKESTER__BUILD_COMMAND ?= $(DOCKER) build -t $(MAKESTER__SERVICE_NAME):$(HASH) .

bi: build-image

build-image:
	-$(MAKESTER__BUILD_COMMAND)

rmi rm-image: rm-image-cmd

IMAGE_TAG_EXISTS = $(shell $(DOCKER) images -q $(MAKESTER__SERVICE_NAME):$(HASH))
rm-image-cmd:
ifneq ($(strip $(IMAGE_TAG_EXISTS)),)
	$(DOCKER) rmi $(MAKESTER__SERVICE_NAME):$(HASH)
endif

run:
	-$(MAKESTER__RUN_COMMAND)

stop:
	-$(DOCKER) stop $(MAKESTER__CONTAINER_NAME)

login-priv:
	-$(DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) sh

logs:
	-$(DOCKER) logs --follow $(MAKESTER__CONTAINER_NAME)

RUNNING_CONTAINER := $(shell docker ps | grep $(MAKESTER__CONTAINER_NAME) | rev | cut -d' ' -f 1 | rev)
status:
ifneq ($(RUNNING_CONTAINER),)
	@echo \"$(MAKESTER__CONTAINER_NAME)\" Docker container is running.  Run \"make stop\" to terminate
else
	@echo \"$(MAKESTER__CONTAINER_NAME)\" Docker container not running. Run \"make run\" to start
endif

tag: IMAGE_TAG = $(shell $(DOCKER) images --filter=reference=$(MAKESTER__SERVICE_NAME) --format "{{.ID}}" | head -1)
tag: build-image
	-$(DOCKER) tag $(IMAGE_TAG) $(MAKESTER__SERVICE_NAME):$(MAKESTER__IMAGE_TAG)

rm-dangling-images:
	$(shell $(DOCKER) rmi $($(DOCKER) images -q -f dangling=true`))

docker-help:
	@echo "(makefiles/docker.mk)\n\
  build-image:         Build docker image $(MAKESTER__SERVICE_NAME):$(HASH) (alias bi)\n\
  rm-image:            Delete docker image $(MAKESTER__SERVICE_NAME):$(HASH) (alias rmi)\n\
  status:              Check container $(MAKESTER__CONTAINER_NAME) run status\n\
  run:                 Run image $(MAKESTER__SERVICE_NAME):$(HASH) as $(MAKESTER__CONTAINER_NAME)\n\
  login-priv:          Login to container $(MAKESTER__CONTAINER_NAME) as user \"root\"\n\
  logs:                Follow container $(MAKESTER__CONTAINER_NAME) logs (Ctrl-C to end)\n\
  stop:                Stop container $(MAKESTER__CONTAINER_NAME)\n\
  tag:                 Build and tag image $(MAKESTER__SERVICE_NAME):latest (default)\n\
  rm-dangling-images:  Remove all dangling images\n"

.PHONY: docker-help
