.DEFAULT_GOAL := help

# Repo-wide globals (stuff you need to make everything work)
GIT = $(shell which git 2>/dev/null)
HASH := $(shell $(GIT) rev-parse --short HEAD)

# Get the name of the project
MAKESTER__PROJECT_NAME ?= $(shell basename $(dir $(realpath $(firstword $(MAKEFILE_LIST)))) | tr A-Z a-z)

# Set Docker image variables.
MAKESTER__REPO_NAME ?= makester
MAKESTER__SERVICE_NAME = $(MAKESTER__REPO_NAME)/$(MAKESTER__PROJECT_NAME)

print-%:
	@echo '$*=$($*)'

clean:
	$(GIT) clean -xdf -e .vagrant -e *.swp -e 2env -e 3env

submodule-update:
	$(GIT) submodule update --init --recursive

help base-help: makester-help

makester-help:
	@echo "\n\
--------------------------------------------------------------------------------------------\n\
Targets\n\
--------------------------------------------------------------------------------------------\n"
	@echo "(makefiles/makester.mk)\n\
  print-<var>:         Display the Makefile global variable '<var>' value\n\
  clean:               Remove all files not tracked by Git\n\
  submodule-update:    update your existing Git submodules\n"

.PHONY: base-help
