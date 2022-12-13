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

# Add PyPI bin to the end of PATH to ensure system Python is found first.
export PATH := $(shell echo $$PATH:$(PWD)/venv/bin)

# Prepare the makester working directory. Place all makester convenience capability here.
MAKESTER__WORK_DIR ?= $(PWD)/.makester
makester-work-dir:
	$(info ### Creating Makester working directory "$(MAKESTER__WORK_DIR)")
	$(shell which mkdir) -pv $(MAKESTER__WORK_DIR)
makester-work-dir-rm:
	$(info ### Clearing empty Makester working directories "$(MAKESTER__WORK_DIR)")
	$(shell which find) $(MAKESTER__WORK_DIR) -depth -type d -empty -exec rmdir {} \;

# Defaults to the current directory (converted to lower case).
ifndef MAKESTER__PROJECT_NAME
  MAKESTER__PROJECT_NAME := $(shell basename $(dir $(realpath $(firstword $(MAKEFILE_LIST)))) | tr A-Z a-z)
endif

# Simulate PyPI package naming convention (replacing hyphens with underscores).
MAKESTER__PACKAGE_NAME ?= $(shell echo $(MAKESTER__PROJECT_NAME) | tr - _)

MAKESTER__PROJECT_DIR ?= $(PWD)

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
MAKESTER__RELEASE_VERSION := $(if $(MAKESTER__RELEASE_VERSION),$(MAKESTER__RELEASE_VERSION),<undefined>)
# Check if MAKESTER__RELEASE_VERSION has been overriden on the CLI.
ifeq (<undefined>,$(MAKESTER__RELEASE_VERSION))
  # MAKESTER__RELEASE_VERSION is not overriden. Check if a release version has been generated.
  ifneq (,$(wildcard $(MAKESTER__WORK_DIR)/release-version))
    MAKESTER__RELEASE_VERSION := $(shell cat $(MAKESTER__WORK_DIR)/release-version)
  endif
endif

# Prepare the makester k8s manifiest directory.
MAKESTER__K8S_MANIFESTS ?= $(MAKESTER__WORK_DIR)/k8s/manifests
makester-k8s-manifest-dir:
	$(info ### Creating Makester k8s manifest directory "$(MAKESTER__K8S_MANIFESTS)")
	$(shell which mkdir) -pv $(MAKESTER__K8S_MANIFESTS)

MAKESTER__RESOURCES_DIR ?= $(MAKESTER__PROJECT_DIR)/makester/resources
makester-gitignore:
	$(info ### Adding a sane .gitignore to "$(MAKESTER__PROJECT_DIR)")
	$(shell which cp) $(MAKESTER__RESOURCES_DIR)/project.gitignore $(MAKESTER__PROJECT_DIR)/.gitignore

makester-mit-license:
	$(info ### Adding MIT license to "$(MAKESTER__PROJECT_DIR)")
	$(shell which cp) $(MAKESTER__RESOURCES_DIR)/mit.md $(MAKESTER__PROJECT_DIR)/LICENSE.md

GIT ?= $(call check-exe,git,https://git-scm.com/downloads)
HASH ?= $(shell $(GIT) rev-parse --short HEAD)

print-%:
	@echo '$*=$($*)'

clean:
	$(GIT) clean -xdf -e .vagrant -e *.swp -e 2env -e 3env -e venv

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
define _check-defined-err
	$(info ### "$1" undefined)
	$(info ### $(if $2,$(value $2)))
	$(error ###)
endef

which-var:
	$(call check-defined,MAKESTER__VAR)
	$(info ### Checking if "$(MAKESTER__VAR)" is defined ...)
	$(call check-defined,$(MAKESTER__VAR),MAKESTER__VAR_INFO)

#   1. Symbol name to be deprecated.
#   2. Makester version when symbol will be deprecated.
#   3. Replacement symbol.
deprecated = $(call _deprecated-err,$1,$2,$3,$(strip $(value 4)))
define _deprecated-err
	$(info ### "$1" will be deprecated in Makester: $2)
    $(info ### Replace "$1" with "$3")
	$(if $4,$(error ###),)
endef

# Check that a dependent executable is available. Exit with an error otherwise.
#
# Params:
#   1. Executable name to test.
#   2. (optional) install tip or message to print.
check-exe = $(strip $(foreach 1,$1,$(call _check-exe,$1,$(strip $(value 2)))))
_check-exe = $(if $(shell PATH=$(PATH); which $1),$(shell PATH=$(PATH); which $1),$(call _check-exe-err,$1,$(if $2,$2)))
define _check-exe-err
	$(info ### "$1" not found)
	$(info ### $(if $2,Install notes: $2))
	$(error ###)
endef

ifndef MAKESTER__LOCAL_IP
  UNAME ?= $(shell uname)
  ifeq ($(UNAME), Darwin)
    MAKESTER__LOCAL_IP := $(shell ipconfig getifaddr en0)
  else ifeq ($(UNAME), Linux)
    MAKESTER__LOCAL_IP := $(shell hostname -I | awk '{print $$1}')
  endif
endif

vars:
	@echo "\n\
  HASH:                              $(HASH)\n\
  MAKESTER__LOCAL_IP:                $(MAKESTER__LOCAL_IP)\n\
  \nStandard override variables:\n\n\
  MAKESTER__K8S_MANIFESTS:           $(MAKESTER__K8S_MANIFESTS)\n\
  MAKESTER__RELEASE_VERSION:         $(MAKESTER__RELEASE_VERSION)\n\
  MAKESTER__WORK_DIR:                $(MAKESTER__WORK_DIR)\n\
  \nOverride variables at the top of your Makefile before the includes:\n\n\
  MAKESTER__PROJECT_DIR:             $(MAKESTER__PROJECT_DIR)\n\
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
  makester-gitignore   Adding a sane .gitignore to \"$(MAKESTER__PROJECT_DIR)\"\n\
  makester-mit-license Remove all files not tracked by Git\n\
  print-<var>          Display the Makefile global variable '<var>' value\n\
  submodule-update     Update your existing Git submodules\n\
  vars                 Display all Makester global variable values\n"

.PHONY: makester-help
