ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := docker-help
endif

# Docker is needed.
DOCKER ?= $(call check-exe,docker,https://docs.docker.com/get-docker/)

MAKESTER__CONTAINER_NAME ?= my-container
MAKESTER__IMAGE_TARGET_TAG ?= $(HASH)

MAKESTER__RUN_COMMAND ?= $(DOCKER) run --rm --name $(MAKESTER__CONTAINER_NAME) $(MAKESTER__SERVICE_NAME):$(HASH)

MAKESTER__BUILD_COMMAND ?= $(DOCKER) build -t $(MAKESTER__SERVICE_NAME):$(HASH) .

si: search-image
search-image:
	-$(DOCKER) images "$(MAKESTER__SERVICE_NAME)*"

bi: build-image

build-image:
	$(MAKESTER__BUILD_COMMAND)

rmi rm-image: rm-image-cmd

rm-image-cmd:
	$(DOCKER) rmi $(MAKESTER__IMAGE_TAG_ALIAS)

run:
	-$(MAKESTER__RUN_COMMAND)

stop:
	-$(DOCKER) stop $(MAKESTER__CONTAINER_NAME)

root:
	-$(DOCKER) exec -ti -u 0 $(MAKESTER__CONTAINER_NAME) sh || true

sh:
	-$(DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) sh || true

bash:
	-$(DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) bash || true

logs:
	-$(DOCKER) logs --follow $(MAKESTER__CONTAINER_NAME)

RUNNING_CONTAINER := $($(DOCKER) ps | grep $(MAKESTER__CONTAINER_NAME) | rev | cut -d' ' -f 1 | rev)
status:
ifneq ($(RUNNING_CONTAINER),)
	@echo \"$(MAKESTER__CONTAINER_NAME)\" Docker container is running.  Run \"make stop\" to terminate
else
	@echo \"$(MAKESTER__CONTAINER_NAME)\" Docker container not running. Run \"make run\" to start
endif

IMAGE_TAG_ID = $(shell $(DOCKER) images --filter=reference=$(MAKESTER__SERVICE_NAME) --format "{{.ID}}" | head -1)
MAKESTER__IMAGE_TAG_ALIAS = $(MAKESTER__SERVICE_NAME):$(MAKESTER__IMAGE_TARGET_TAG)
tag tag-image:
	-$(DOCKER) tag $(IMAGE_TAG_ID) $(MAKESTER__IMAGE_TAG_ALIAS)

tag-latest: MAKESTER__IMAGE_TARGET_TAG = latest
tag-latest: tag

tag-rm-latest: MAKESTER__IMAGE_TARGET_TAG = latest
tag-rm-latest: rmi

tag-version: MAKESTER__IMAGE_TARGET_TAG = $(MAKESTER__VERSION)-$(MAKESTER__RELEASE_NUMBER)
tag-version: tag

tag-rm-version: MAKESTER__IMAGE_TARGET_TAG = $(MAKESTER__VERSION)-$(MAKESTER__RELEASE_NUMBER)
tag-rm-version: rmi

tag-main: MAKESTER__IMAGE_TARGET_TAG = $(MAKESTER__VERSION)
tag-main: tag

tag-rm-main: MAKESTER__IMAGE_TARGET_TAG = $(MAKESTER__VERSION)
tag-rm-main: rmi

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
  root                 Shell on container $(MAKESTER__CONTAINER_NAME) as user \"root\"\n\
  sh                   Shell on container $(MAKESTER__CONTAINER_NAME) as \"USER\"\n\
  bash                 Bash on container $(MAKESTER__CONTAINER_NAME) as \"USER\"\n\
  logs                 Follow container $(MAKESTER__CONTAINER_NAME) logs (Ctrl-C to end)\n\
  stop                 Stop container $(MAKESTER__CONTAINER_NAME)\n\
  tag-image            Tag image $(MAKESTER__SERVICE_NAME) \"$(HASH)\"\n\
  tag-rm-image         Undo \"tag-image\"\n\
  tag-latest           Tag image $(MAKESTER__SERVICE_NAME) \"latest\"\n\
  tag-rm-latest        Undo \"tag-latest\"\n\
  tag-version          Tag image $(MAKESTER__SERVICE_NAME) \"$(MAKESTER__VERSION)-$(MAKESTER__RELEASE_NUMBER)\"\n\
  tag-rm-version       Undo \"tag-version\"\n\
  tag-main             Tag image $(MAKESTER__SERVICE_NAME) \"$(MAKESTER__VERSION)\"\n\
  tag-rm-main          Undo \"tag-main\"\n\
  rm-dangling-images   Remove all dangling images\n\
  image-push           Push image \"$(MAKESTER__IMAGE_TAG_ALIAS)\"\n"

.PHONY: docker-help
