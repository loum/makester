ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := docker-help
endif

ifndef MAKESTER__PRIMED
$(info ### Add the following include statement to your Makefile)
$(info include makester/makefiles/makester.mk)
$(error ### missing include dependency)
endif

# Defaults that can be overridden.
MAKESTER__DOCKER_EXE_NAME ?= docker
MAKESTER__DOCKER_EXE_INSTALL ?= https://docs.docker.com/get-docker

ifndef MAKESTER__DOCKER
  MAKESTER__DOCKER ?= $(call check-exe,$(MAKESTER__DOCKER_EXE_NAME),$(MAKESTER__DOCKER_EXE_INSTALL),optional)
endif

MAKESTER__CONTAINER_NAME ?= my-container
MAKESTER__IMAGE_TARGET_TAG ?= $(HASH)

MAKESTER__RUN_COMMAND ?= $(MAKESTER__DOCKER) run --rm --name $(MAKESTER__CONTAINER_NAME) $(MAKESTER__SERVICE_NAME):$(HASH)

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

#
# Best guess-timate at the type of platform to build the container image against.
#
ifndef MAKESTER__DOCKER_PLATFORM
  ifeq ($(MAKESTER__ARCH), arm64)
    MAKESTER__DOCKER_PLATFORM ?= linux/arm64
  else
    MAKESTER__DOCKER_PLATFORM ?= linux/amd64
  endif
endif

#
# Deploy local registry server for container images.
#
MAKESTER__LOCAL_REGISTRY_RUNNING ?= $(shell $(MAKESTER__DOCKER) ps | grep makester-registry | rev | cut -d' ' -f 1 | rev)
#$(info ### MAKESTER__LOCAL_REGISTRY_RUNNING $(MAKESTER__LOCAL_REGISTRY_RUNNING))

MAKESTER__LOCAL_REGISTRY_IMAGE ?= registry:2
MAKESTER__LOCAL_REGISTRY_PORT ?= 15000
ifndef MAKESTER__LOCAL_REGISTRY
	MAKESTER__LOCAL_REGISTRY ?= 0.0.0.0:5000
endif

_image-registry-backoff:
	@$(MAKESTER__BIN)/makester backoff $(MAKESTER__LOCAL_IP) $(MAKESTER__LOCAL_REGISTRY_PORT) --detail "Local registry server"

_image-registry-start:
ifeq ($(call MAKESTER__LOCAL_REGISTRY_RUNNING),makester-registry)
	$(info ### makester-registry is running. Run "make image-registry-stop" to terminate.)
else
	$(info ### Starting local Docker image registry ...)
	$(MAKESTER__DOCKER) run --rm -d\
 -e REGISTRY_HTTP_ADDR=$(MAKESTER__LOCAL_REGISTRY)\
 -p $(MAKESTER__LOCAL_REGISTRY_PORT):5000\
 --name makester-registry\
 $(MAKESTER__LOCAL_REGISTRY_IMAGE)
endif

MAKESTER__BUILDKIT_BUILDER_NAME ?= multiarch
image-buildx-builder:
	$(info ### Creating BuildKit builder "$(MAKESTER__BUILDKIT_BUILDER_NAME)" (if required) ...)
	-$(MAKESTER__DOCKER) buildx create --driver-opt network=host --name $(MAKESTER__BUILDKIT_BUILDER_NAME) --use

image-registry-start: _image-registry-start _image-registry-backoff

image-registry-stop:
ifeq ($(call MAKESTER__LOCAL_REGISTRY_RUNNING),makester-registry)
	$(info ### Stopping local Docker image registry.)
	$(MAKESTER__DOCKER) container stop makester-registry
else
	$(info ### makester-registry is not running. Run "make image-registry-start" to start.)
endif

#
# Docker builder driver output type based on whether local server registry is running.
#
ifndef MAKESTER__DOCKER_DRIVER_OUTPUT
  ifeq ($(call MAKESTER__LOCAL_REGISTRY_RUNNING),makester-registry) # Local image registry is running.
    MAKESTER__DOCKER_DRIVER_OUTPUT ?= push
  else
    MAKESTER__DOCKER_DRIVER_OUTPUT ?= load
  endif
endif

ifeq ($(call MAKESTER__LOCAL_REGISTRY_RUNNING),makester-registry) # Local image registry is running.
  MAKESTER__SERVICE_NAME := localhost:$(value MAKESTER__LOCAL_REGISTRY_PORT)/$(MAKESTER__SERVICE_NAME)
endif

MAKESTER__IMAGE_TAG_ALIAS ?= $(MAKESTER__SERVICE_NAME):$(MAKESTER__IMAGE_TARGET_TAG)

MAKESTER__BUILD_CONTEXT ?= build
MAKESTER__BUILD_PATH ?= .
MAKESTER__BUILD_COMMAND ?= -t $(MAKESTER__SERVICE_NAME):$(MAKESTER__IMAGE_TARGET_TAG) $(MAKESTER__BUILD_PATH)

ib image-build bi:
	$(MAKESTER__DOCKER) $(MAKESTER__BUILD_CONTEXT) $(MAKESTER__BUILD_COMMAND)

ibx image-buildx: MAKESTER__BUILD_CONTEXT := buildx build --platform $(MAKESTER__DOCKER_PLATFORM) --$(MAKESTER__DOCKER_DRIVER_OUTPUT)
ibx image-buildx: image-build

irm image-rm rmi rm-image:
	$(MAKESTER__DOCKER) rmi $(MAKESTER__IMAGE_TAG_ALIAS)

# Symbol to be deprecated in Makester 0.3.0
tag-image: _tag-image-warn image-tag
_tag-image-warn:
	$(call deprecated,tag-image,0.3.0,image-tag)

define _image-tag-id
$(shell $(MAKESTER__DOCKER) images --filter=reference=$(MAKESTER__SERVICE_NAME) --format "{{.ID}}" | head -1)
endef

image-tag tag:
	-$(MAKESTER__DOCKER) tag $(call _image-tag-id) $(MAKESTER__IMAGE_TAG_ALIAS)

_image-tag-msg:
	$(info ### Tagging container image "$(MAKESTER__SERVICE_NAME)" as "$(MAKESTER__IMAGE_TARGET_TAG)")
_image-tag-rm-msg:
	$(info ### Removing tag "$(MAKESTER__IMAGE_TARGET_TAG)" from container image "$(MAKESTER__SERVICE_NAME)")

image-tag-latest tag-latest: MAKESTER__IMAGE_TARGET_TAG = latest
image-tag-latest tag-latest: _image-tag-msg tag

image-tag-latest-rm tag-rm-latest: MAKESTER__IMAGE_TARGET_TAG = latest
image-tag-latest-rm tag-rm-latest: _image-tag-rm-msg image-rm

image-tag-version tag-version: MAKESTER__IMAGE_TARGET_TAG = $(MAKESTER__VERSION)-$(MAKESTER__RELEASE_NUMBER)
image-tag-version tag-version: _image-tag-msg tag

image-tag-version-rm tag-rm-version: MAKESTER__IMAGE_TARGET_TAG = $(MAKESTER__VERSION)-$(MAKESTER__RELEASE_NUMBER)
image-tag-version-rm tag-rm-version: _image-tag-rm-msg image-rm

image-tag-main tag-main: MAKESTER__IMAGE_TARGET_TAG = $(MAKESTER__VERSION)
image-tag-main tag-main: _image-tag-msg tag

image-tag-main-rm tag-rm-main: MAKESTER__IMAGE_TARGET_TAG = $(MAKESTER__VERSION)
image-tag-main-rm tag-rm-main: _image-tag-rm-msg image-rm

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

MAKESTER__RUNNING_CONTAINER ?= $(shell $(MAKESTER__DOCKER) ps | grep $(MAKESTER__CONTAINER_NAME) | rev | cut -d' ' -f 1 | rev)

container-status:
ifeq ($(call MAKESTER__RUNNING_CONTAINER),)
	$(info ### "$(MAKESTER__CONTAINER_NAME)" image container is not running.)
	$(info ### Run "make container-run" to start.)
else
	$(info ### "$(MAKESTER__CONTAINER_NAME)" image container is running.)
	$(info ### Run "make container-stop" to terminate.)
endif

docker-help:
	printf "\n($(MAKESTER__MAKEFILES)/docker.mk)\n"
	$(call help-line,container-bash,Bash on container $(MAKESTER__CONTAINER_NAME) as \"USER\")
	$(call help-line,container-logs,Follow container $(MAKESTER__CONTAINER_NAME) logs (Ctrl-C to end))
	$(call help-line,container-root,Shell on container $(MAKESTER__CONTAINER_NAME) as user \"root\")
	$(call help-line,container-run,Run image $(MAKESTER__SERVICE_NAME):$(HASH) as $(MAKESTER__CONTAINER_NAME))
	$(call help-line,container-sh,Shell on container $(MAKESTER__CONTAINER_NAME) as \"USER\")
	$(call help-line,container-status,Check container $(MAKESTER__CONTAINER_NAME) run status)
	$(call help-line,container-stop,Stop container $(MAKESTER__CONTAINER_NAME))
	$(call help-line,image-build,Build docker image and tag as $(MAKESTER__IMAGE_TAG_ALIAS))
	$(call help-line,image-buildx,Build docker image and tag as $(MAKESTER__IMAGE_TAG_ALIAS) with BuildKit)
	$(call help-line,image-push,Push image \"$(MAKESTER__IMAGE_TAG_ALIAS)\")
	$(call help-line,image-registry-start,Deploy a local image registry server)
	$(call help-line,image-registry-stop,Stop the local image registry server)
	$(call help-line,image-rm,Delete docker image \"$(MAKESTER__IMAGE_TAG_ALIAS)\")
	$(call help-line,image-rm-dangling,Remove all dangling images)
	$(call help-line,image-search,List docker images that match \"$(MAKESTER__SERVICE_NAME)*\")
	$(call help-line,image-tag,Tag image $(MAKESTER__SERVICE_NAME) \"$(HASH)\" (as per default build))
	$(call help-line,image-tag-latest,Tag image $(MAKESTER__SERVICE_NAME) \"latest\")
	$(call help-line,image-tag-latest-rm,Undo \"image-tag-latest\")
	$(call help-line,image-tag-main,Tag image $(MAKESTER__SERVICE_NAME) \"$(MAKESTER__VERSION)\")
	$(call help-line,image-tag-main-rm,Undo \"image-tag-main\")
	$(call help-line,image-tag-suite,Convenience image create and tag all-in-one helper)
	$(call help-line,image-tag-suite-rm,Convenience image tag and image delete all-in-one helper)
	$(call help-line,image-tag-version,Tag image $(MAKESTER__SERVICE_NAME) \"$(MAKESTER__VERSION)-$(MAKESTER__RELEASE_NUMBER)\")
	$(call help-line,image-tag-version-rm,Undo \"image-tag-version\")

.PHONY: docker-help
