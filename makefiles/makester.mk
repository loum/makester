.DEFAULT_GOAL := help

# Repo-wide globals (stuff you need to make everything work)
GIT = $(shell which git 2>/dev/null)
HASH := $(shell $(GIT) rev-parse --short HEAD)

# Set Docker variables to be used throughout the project.
MAKESTER__PROJECT_NAME ?= $(shell basename $(dir $(realpath $(firstword $(MAKEFILE_LIST)))) | tr A-Z a-z)
MAKESTER__CONTAINER_NAME ?= my-container

MAKESTER__IMAGE_TAG ?= latest

print-%:
	@echo '$*=$($*)'

clean:
	$(GIT) clean -xdf -e .vagrant -e *.swp -e 2env -e 3env

submodule-update:
	$(GIT) submodule update --remote --merge

help base-help: makester-help

makester-help:
	@echo "\n\
--------------------------------------------------------------------------------------------\n\
Targets\n\
--------------------------------------------------------------------------------------------\n"
	@echo "(makefiles/makester.mk)\n\
  print-<var>:         Display the Makefile global variable '<var>' value\n\
  clean:               Remove all files not tracked by Git\n\
  submodule-update:    Update your existing Git submodules\n"

.PHONY: base-help
