.SILENT:
ifndef .DEFAULT_GOAL
  .DEFAULT_GOAL := makester-help
endif

# Set this to true to indicate that this Makefile has been read.
ifndef MAKESTER__PRIMED
  MAKESTER__PRIMED ?= true
endif

ifndef MAKESTER__VERBOSE
  MAKEFLAGS += --no-print-directory
endif

# Prepare the makester working directory. Place all makester convenience capability here.
MAKESTER__WORK_DIR ?= $(PWD)/.makester
ifeq (,$(wildcard $(MAKESTER__WORK_DIR)))
  $(shell $(shell which mkdir) -p $(MAKESTER__WORK_DIR))
endif

# Defaults to the current directory (converted to lower case).
ifndef MAKESTER__PROJECT_NAME
  MAKESTER__PROJECT_NAME := $(shell basename $(dir $(realpath $(firstword $(MAKEFILE_LIST)))) | tr A-Z a-z)
endif

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

GIT ?= $(call check-exe,git,https://git-scm.com/downloads)
HASH ?= $(shell $(GIT) rev-parse --short HEAD)

print-%:
	@echo '$*=$($*)'

clean:
	$(GIT) clean -xdf -e .vagrant -e *.swp -e 2env -e 3env

submodule-update:
	$(GIT) submodule update --remote --merge

# Check that given variables are set and all have non-empty values.  # Exit with an error otherwise.
# See https://stackoverflow.com/questions/10858261/abort-makefile-if-variable-not-set
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check-defined = $(strip $(foreach 1,$1,$(call _check-defined,$1,$(strip $(value 2)))))
_check-defined = $(if $(value $1),,$(call _check-defined-err,$1,$(if $2,$(value 2))))
_check-defined-err = $(info ### "$1" undefined) $(info ### $(if $2,$(value $2))) $(error ###)

which-var:
	$(call check-defined,MAKESTER__VAR)
	$(info ### Checking if "$(MAKESTER__VAR)" is defined ...)
	$(call check-defined,$(MAKESTER__VAR),MAKESTER__VAR_INFO)

# Check that a dependent executable is available. Exit with an error otherwise.
#
# Params:
#   1. Executable name to test.
#   2. (optional) install tip or message to print.
check-exe = $(strip $(foreach 1,$1,$(call _check-exe,$1,$(strip $(value 2)))))
_check-exe = $(if $(shell which $1),$(shell which $1),$(call _check-exe-err,$1,$(if $2,$2)))
_check-exe-err = $(info ### "$1" not found) $(info ### $(if $2,Install notes: $2)) $(error ###)

UNAME ?= $(shell uname)
ifeq ($(UNAME), Darwin)
  MAKESTER__LOCAL_IP ?= $(shell ipconfig getifaddr en0)
else ifeq ($(UNAME), Linux)
  MAKESTER__LOCAL_IP ?= $(shell hostname -I | awk '{print $$1}')
endif

vars:
	@echo "\n\
  HASH:                              $(HASH)\n\
  MAKESTER__LOCAL_IP:                $(MAKESTER__LOCAL_IP)\n\
  MAKESTER__WORK_DIR                 $(MAKESTER__WORK_DIR)\n\
  \nOverride variables at the top of your Makefile before the includes:\n\n\
  MAKESTER__PROJECT_NAME:            $(MAKESTER__PROJECT_NAME)\n\
  MAKESTER__RELEASE_NUMBER:          $(MAKESTER__RELEASE_NUMBER)\n\
  MAKESTER__REPO_NAME:               $(MAKESTER__REPO_NAME)\n\
  MAKESTER__SERVICE_NAME:            $(MAKESTER__SERVICE_NAME)\n\
  MAKESTER__VERSION:                 $(MAKESTER__VERSION)\n"

makester-help:
	@echo "\n\
--------------------------------------------------------------------------------------------\n\
Targets\n\
--------------------------------------------------------------------------------------------\n"
	@echo "(makefiles/makester.mk)\n\
  clean                Remove all files not tracked by Git\n\
  print-<var>          Display the Makefile global variable '<var>' value\n\
  submodule-update     Update your existing Git submodules\n\
  vars                 Display all Makester global variable values\n"

.PHONY: makester-help
