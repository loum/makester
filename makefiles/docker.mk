ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := docker-help
endif

ifndef MAKESTER__PRIMED
$(info ### Add the following include statement to your Makefile)
$(info include makester/makefiles/makester.mk)
$(error ### missing include dependency)
endif

# Docker is needed.
MAKESTER__DOCKER ?= $(call check-exe,docker,https://docs.docker.com/get-docker/)

MAKESTER__CONTAINER_NAME ?= my-container
MAKESTER__IMAGE_TARGET_TAG ?= $(HASH)

MAKESTER__RUN_COMMAND ?= $(MAKESTER__DOCKER) run --rm --name $(MAKESTER__CONTAINER_NAME) $(MAKESTER__SERVICE_NAME):$(HASH)

MAKESTER__BUILD_CONTEXT ?= build
MAKESTER__BUILD_PATH ?= .
MAKESTER__BUILD_COMMAND ?= -t $(MAKESTER__SERVICE_NAME):$(MAKESTER__IMAGE_TARGET_TAG) $(MAKESTER__BUILD_PATH)

# 20221027: Introduced target grouping for "image" related items.
#
# Symbol to be deprecated in Makester 0.3.0
search-image: _search-image-warn image-search
_search-image-warn:
	$(call deprecated,search-image,0.3.0,image-search)

is image-search si:
	-$(MAKESTER__DOCKER) images "$(MAKESTER__SERVICE_NAME)*"

# Symbol to be deprecated in Makester 0.3.0
build-image: _build-image-warn image-build
_build-image-warn:
	$(call deprecated,build-image,0.3.0,image-build)

ib image-build bi:
	$(MAKESTER__DOCKER) $(MAKESTER__BUILD_CONTEXT) $(MAKESTER__BUILD_COMMAND)

ibx image-buildx: MAKESTER__BUILD_CONTEXT := buildx build
ibx image-buildx: image-build

irm image-rm rmi rm-image:
	$(MAKESTER__DOCKER) rmi $(MAKESTER__IMAGE_TAG_ALIAS)

# Symbol to be deprecated in Makester 0.3.0
tag-image: _tag-image-warn image-tag
_tag-image-warn:
	$(call deprecated,tag-image,0.3.0,image-tag)

IMAGE_TAG_ID := $(shell $(MAKESTER__DOCKER) images --filter=reference=$(MAKESTER__SERVICE_NAME) --format "{{.ID}}" | head -1)
MAKESTER__IMAGE_TAG_ALIAS ?= $(MAKESTER__SERVICE_NAME):$(MAKESTER__IMAGE_TARGET_TAG)
image-tag tag:
	-$(MAKESTER__DOCKER) tag $(IMAGE_TAG_ID) $(MAKESTER__IMAGE_TAG_ALIAS)

_image-tag-msg:
	$(info ### Tagging container image "$(MAKESTER__SERVICE_NAME)" as "$(MAKESTER__IMAGE_TARGET_TAG)")
_image-tag-rm-msg:
	$(info ### Removing tag "$(MAKESTER__IMAGE_TARGET_TAG)" from container image "$(MAKESTER__SERVICE_NAME)")

image-tag-latest tag-latest: MAKESTER__IMAGE_TARGET_TAG = latest
image-tag-latest tag-latest: _image-tag-msg tag

image-tag-latest-rm tag-rm-latest: MAKESTER__IMAGE_TARGET_TAG = latest
image-tag-latest-rm tag-rm-latest: _image-tag-rm-msg rmi

image-tag-version tag-version: MAKESTER__IMAGE_TARGET_TAG = $(MAKESTER__VERSION)-$(MAKESTER__RELEASE_NUMBER)
image-tag-version tag-version: _image-tag-msg tag

image-tag-version-rm tag-rm-version: MAKESTER__IMAGE_TARGET_TAG = $(MAKESTER__VERSION)-$(MAKESTER__RELEASE_NUMBER)
image-tag-version-rm tag-rm-version: _image-tag-rm-msg rmi

image-tag-main tag-main: MAKESTER__IMAGE_TARGET_TAG = $(MAKESTER__VERSION)
image-tag-main tag-main: _image-tag-msg tag

image-tag-main-rm tag-rm-main: MAKESTER__IMAGE_TARGET_TAG = $(MAKESTER__VERSION)
image-tag-main-rm tag-rm-main: _image-tag-rm-msg rmi

image-tag-suite: image-tag-latest image-tag-main image-tag-version
	$(info ### Container image tag create suite ...)
	$(MAKE) image-tag-latest
	$(MAKE) image-tag-main
	$(MAKE) image-tag-version
image-tag-suite-rm:
	$(info ### Container image tag delete suite ...)
	$(MAKE) image-tag-latest-rm
	$(MAKE) image-tag-main-rm
	$(MAKE) image-tag-version-rm

image-push:
	-$(MAKESTER__DOCKER) push $(MAKESTER__IMAGE_TAG_ALIAS)

image-rm-dangling rm-dangling-images:
	-$(shell $(MAKESTER__DOCKER) rmi $(shell $(MAKESTER__DOCKER) images -f "dangling=true" -q))

MAKESTER__LOCAL_REGISTRY_IMAGE ?= registry:2
MAKESTER__LOCAL_REGISTRY_IP ?= 15000
MAKESTER__LOCAL_REGISTRY := $(MAKESTER__LOCAL_IP):$(MAKESTER__LOCAL_REGISTRY_IP)

_LOCAL_REGISTRY_IS_ACTIVE ?= $(shell $(MAKESTER__DOCKER) ps | grep makester-registry | rev | cut -d' ' -f 1 | rev)
image-registry-start:
ifneq ($(_LOCAL_REGISTRY_IS_ACTIVE),)
	$(info ### makester-registry is running. Run "make image-registry-stop" to terminate.)
else
	$(info ### Starting local Docker image registry at $(MAKESTER__LOCAL_REGISTRY))
	$(MAKESTER__DOCKER) run --rm -d -p $(MAKESTER__LOCAL_REGISTRY_IP):5000\
 --name makester-registry\
 $(MAKESTER__LOCAL_REGISTRY_IMAGE)
endif

image-registry-stop:
ifneq ($(_LOCAL_REGISTRY_IS_ACTIVE),)
	$(info ### Stopping local Docker image registry at $(MAKESTER__LOCAL_REGISTRY))
	$(MAKESTER__DOCKER) container stop makester-registry
else
	$(info ### makester-registry is not running. Run "make image-registry-start" to start.)
endif

# 20221027: Introduced target grouping for "container" related items.
#
# Symbol to be deprecated in Makester 0.3.0
run: _run-warn container-run
_run-warn:
	$(call deprecated,run,0.3.0,container-run)

container-run:
	-$(MAKESTER__RUN_COMMAND)

# Symbol to be deprecated in Makester 0.3.0
stop: _stop-warn container-stop
_stop-warn:
	$(call deprecated,stop,0.3.0,container-stop)

container-stop:
	-$(MAKESTER__DOCKER) stop $(MAKESTER__CONTAINER_NAME)

# Symbol to be deprecated in Makester 0.3.0
root: _root-warn container-root
_root-warn:
	$(call deprecated,root,0.3.0,container-root)

container-root:
	-$(MAKESTER__DOCKER) exec -ti -u 0 $(MAKESTER__CONTAINER_NAME) sh || true

# Symbol to be deprecated in Makester 0.3.0
sh: _sh-warn container-sh
_sh-warn:
	$(call deprecated,sh,0.3.0,container-sh)

container-sh:
	-$(MAKESTER__DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) sh || true

# Symbol to be deprecated in Makester 0.3.0
bash: _bash-warn container-bash
_bash-warn:
	$(call deprecated,bash,0.3.0,container-bash)

container-bash:
	-$(MAKESTER__DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) bash || true

# Symbol to be deprecated in Makester 0.3.0
logs: _logs-warn container-logs
_logs-warn:
	$(call deprecated,logs,0.3.0,container-logs)

container-logs:
	-$(MAKESTER__DOCKER) logs --follow $(MAKESTER__CONTAINER_NAME)

# Symbol to be deprecated in Makester 0.3.0
status: _status-warn container-status
_status-warn:
	$(call deprecated,status,0.3.0,container-status)

RUNNING_CONTAINER := $($(MAKESTER__DOCKER) ps | grep $(MAKESTER__CONTAINER_NAME) | rev | cut -d' ' -f 1 | rev)
container-status:
ifneq ($(RUNNING_CONTAINER),)
	@echo \"$(MAKESTER__CONTAINER_NAME)\" Docker container is running.  Run \"make stop\" to terminate
else
	@echo \"$(MAKESTER__CONTAINER_NAME)\" Docker container not running. Run \"make run\" to start
endif

docker-help:
	@echo "($(MAKESTER__MAKEFILES)/docker.mk)\n\
  container-bash       Bash on container $(MAKESTER__CONTAINER_NAME) as \"USER\"\n\
  container-logs       Follow container $(MAKESTER__CONTAINER_NAME) logs (Ctrl-C to end)\n\
  container-root       Shell on container $(MAKESTER__CONTAINER_NAME) as user \"root\"\n\
  container-run        Run image $(MAKESTER__SERVICE_NAME):$(HASH) as $(MAKESTER__CONTAINER_NAME)\n\
  container-sh         Shell on container $(MAKESTER__CONTAINER_NAME) as \"USER\"\n\
  container-status     Check container $(MAKESTER__CONTAINER_NAME) run status\n\
  container-stop       Stop container $(MAKESTER__CONTAINER_NAME)\n\
  image-build          Build docker image and tag as $(MAKESTER__IMAGE_TAG_ALIAS) (alias bi)\n\
  image-buildx         Build docker image and tag as $(MAKESTER__IMAGE_TAG_ALIAS) with BuildKit\n\
  image-push           Push image \"$(MAKESTER__IMAGE_TAG_ALIAS)\"\n\
  image-rm             Delete docker image \"$(MAKESTER__IMAGE_TAG_ALIAS)\" (alias rmi)\n\
  image-rm-dangling    Remove all dangling images\n\
  image-registry-start Deploy a local image registry server\n\
  image-registry-stop  Stop the local image registry server\n\
  image-search         List docker images that match \"$(MAKESTER__SERVICE_NAME)*\" (alias si)\n\
  image-tag            Tag image $(MAKESTER__SERVICE_NAME) \"$(HASH)\" (as per default build)\n\
  image-tag-latest     Tag image $(MAKESTER__SERVICE_NAME) \"latest\"\n\
  image-tag-latest-rm  Undo \"image-tag-latest\"\n\
  image-tag-main       Tag image $(MAKESTER__SERVICE_NAME) \"$(MAKESTER__VERSION)\"\n\
  image-tag-main-rm    Undo \"image-tag-main\"\n\
  image-tag-suite      Convenience image create and tag all-in-one helper\n\
  image-tag-suite-rm   Convenience image tag and image delete all-in-one helper\n\
  image-tag-version    Tag image $(MAKESTER__SERVICE_NAME) \"$(MAKESTER__VERSION)-$(MAKESTER__RELEASE_NUMBER)\"\n\
  image-tag-version-rm Undo \"image-tag-version\"\n"

.PHONY: docker-help
