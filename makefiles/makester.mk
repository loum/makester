.DEFAULT_GOAL := help

MAKESTER__PROJECT_NAME := $(shell basename $(dir $(realpath $(firstword $(MAKEFILE_LIST)))) | tr A-Z a-z)

# MAKESTER__SERVICE_NAME supports optional MAKESTER__REPO_NAME.
ifeq ($(strip $(MAKESTER__SERVICE_NAME)),)
    ifeq ($(strip $(MAKESTER__REPO_NAME)),)
        MAKESTER__SERVICE_NAME := $(MAKESTER__PROJECT_NAME)
    else
        MAKESTER__SERVICE_NAME := $(MAKESTER__REPO_NAME)/$(MAKESTER__PROJECT_NAME)
    endif
endif

# Default versioning.
MAKESTER__VERSION := $(if $(MAKESTER__VERSION),$(MAKESTER__VERSION),0.0.0)
MAKESTER__RELEASE_NUMBER := $(if $(MAKESTER__RELEASE_NUMBER),$(MAKESTER__RELEASE_NUMBER),1)

# Repo-wide globals (stuff you need to make everything work)
GIT := $(shell which git 2>/dev/null)
HASH := $(shell $(GIT) rev-parse --short HEAD)

print-%:
	@echo '$*=$($*)'

clean:
	$(GIT) clean -xdf -e .vagrant -e *.swp -e 2env -e 3env

submodule-update:
	$(GIT) submodule update --remote --merge

vars:
	@echo "\nOverride non run time variables at the top of your Makefile before the includes:\n\n\
  MAKESTER__PROJECT_NAME:            $(MAKESTER__PROJECT_NAME)\n\
  MAKESTER__RELEASE_NUMBER:          $(MAKESTER__RELEASE_NUMBER)\n\
  MAKESTER__REPO_NAME:               $(MAKESTER__REPO_NAME)\n\
  MAKESTER__SERVICE_NAME:            $(MAKESTER__SERVICE_NAME)\n\
  MAKESTER__VERSION:                 $(MAKESTER__VERSION)\n"

help base-help: makester-help

help: makester-help

makester-help:
	@echo "\n\
--------------------------------------------------------------------------------------------\n\
Targets\n\
--------------------------------------------------------------------------------------------\n"
	@echo "(makefiles/makester.mk)\n\
  vars                 Display all Makester global variable values\n\
  print-<var>          Display the Makefile global variable '<var>' value\n\
  clean                Remove all files not tracked by Git\n\
  submodule-update     Update your existing Git submodules\n"

.PHONY: vars help
