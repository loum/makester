include python-venv.mk
include utils.mk

# Get the name of the project
PROJECT_NAME := $(shell basename $(dir $(realpath $(firstword $(MAKEFILE_LIST)))) | tr A-Z a-z)

# Set Docker image variables.
DOCKER_MAKE__REPO_NAME := loum
DOCKER_MAKE__SERVICE_NAME := $(DOCKER_MAKE__REPO_NAME)/$(PROJECT_NAME)

bi: build-image

build-image:
	@$(DOCKER) build -t $(SERVICE_NAME):$(HASH) .

rmi: rm-image

rm-image:
	@$(DOCKER) rmi $(SERVICE_NAME):$(HASH) || true

rm-dangling-images:
	@$(DOCKER) images -q -f dangling=true && \
      $(DOCKER) rmi `$(DOCKER) images -q -f dangling=true` || true

help: utils-help
	@echo "\n\
  (Makefile)\n\
  build-image:      Build docker image $(DOCKER_MAKE__SERVICE_NAME):$(HASH)\n\
  rm-image:         Delete docker image $(DOCKER_MAKE__SERVICE_NAME):$(HASH)\n\
  rm-dangling-images:   Remove dangling docker images\n\
	";

.PHONY: help
