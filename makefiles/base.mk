# Get the name of the project
PROJECT_NAME := $(shell basename $(dir $(realpath $(firstword $(MAKEFILE_LIST)))) | tr A-Z a-z)

# Set Docker image variables.
MAKESTER__REPO_NAME ?= loum
MAKESTER__SERVICE_NAME = $(MAKESTER__REPO_NAME)/$(PROJECT_NAME)

print-%:
	@echo '$*=$($*)'

clean:
	$(GIT) clean -xdf -e .vagrant -e *.swp -e 2env -e 3env

# Repo-wide globals (stuff you need to make everything work)
GIT := $(shell which git 2>/dev/null)
HASH := $(shell $(GIT) rev-parse --short HEAD)
DOCKER_COMPOSE := $(shell which docker-compose 2>/dev/null || echo "3env/bin/docker-compose")

base-help:
	@echo "Targets\n\
------------------------------------------------------------------------\n\
	";
	@echo "(makefiles/base.mk)\n\
  print-<var>:         Display the Makefile global variable '<var>' value\n\
  clean:               Remove all files not tracked by Git\n\
	";

.PHONY: base-help
