DOCKER := $(shell which docker 2>/dev/null)

MAKESTER__CONTAINER_NAME = my-container
MAKESTER__IMAGE_TARGET_TAG = latest

# MAKESTER__SERVICE_NAME supports optional MAKESTER__REPO_NAME.
MAKESTER__REPO_NAME = $(if $(MAKESTER__REPO_NAME),$(MAKESTER__REPO_NAME),)
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

si: search-image
search-image:
	-$(DOCKER) images "$(MAKESTER__SERVICE_NAME)*"

bi: build-image

build-image:
	-$(MAKESTER__BUILD_COMMAND)

rmi rm-image: rm-image-cmd

IMAGE_TAG_EXISTS = $(shell $(DOCKER) images -q $(MAKESTER__IMAGE_TAG_ALIAS))
rm-image-cmd:
ifneq ($(strip $(IMAGE_TAG_EXISTS)),)
	$(DOCKER) rmi $(MAKESTER__IMAGE_TAG_ALIAS)
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

IMAGE_TAG_ID = $(shell $(DOCKER) images --filter=reference=$(MAKESTER__SERVICE_NAME) --format "{{.ID}}" | head -1)
MAKESTER__IMAGE_TAG_ALIAS = $(MAKESTER__SERVICE_NAME):$(MAKESTER__IMAGE_TARGET_TAG)
tag:
	-$(DOCKER) tag $(IMAGE_TAG_ID) $(MAKESTER__IMAGE_TAG_ALIAS)

tag-version: MAKESTER__IMAGE_TARGET_TAG = $(MAKESTER__VERSION)-$(MAKESTER__RELEASE_NUMBER)
tag-version: tag

image-push:
	-$(DOCKER) push $(MAKESTER__IMAGE_TAG_ALIAS)

rm-dangling-images:
	$(shell $(DOCKER) rmi $($(DOCKER) images -q -f dangling=true`))

docker-help:
	@echo "(makefiles/docker.mk)\n\
  build-image          Build docker image and tag as $(MAKESTER__IMAGE_TAG_ALIAS) (alias bi)\n\
  rm-image             Delete docker image \"$(MAKESTER__IMAGE_TAG_ALIAS)\" (alias rmi)\n\
  search-image         List docker images that match \"$(MAKESTER__SERVICE_NAME)*\" (alias si)\n\
  status               Check container $(MAKESTER__CONTAINER_NAME) run status\n\
  run                  Run image $(MAKESTER__SERVICE_NAME):$(HASH) as $(MAKESTER__CONTAINER_NAME)\n\
  login-priv           Login to container $(MAKESTER__CONTAINER_NAME) as user \"root\"\n\
  logs                 Follow container $(MAKESTER__CONTAINER_NAME) logs (Ctrl-C to end)\n\
  stop                 Stop container $(MAKESTER__CONTAINER_NAME)\n\
  tag                  Build and tag image \"$(MAKESTER__IMAGE_TAG_ALIAS)\"\n\
  tag-version          Tag image $(MAKESTER__SERVICE_NAME) \"$(MAKESTER__VERSION)-$(MAKESTER__RELEASE_NUMBER)\"\n\
  rm-dangling-images   Remove all dangling images\n\
  image-push           Push image \"$(MAKESTER__IMAGE_TAG_ALIAS)\"\n"

.PHONY: docker-help
