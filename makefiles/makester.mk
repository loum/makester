ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := makester-help
endif

# Defaults to the current directory (converted to lower case).
MAKESTER__PROJECT_NAME = $(shell basename $(dir $(realpath $(firstword $(MAKEFILE_LIST)))) | tr A-Z a-z)

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

# Check that given variables are set and all have non-empty values.
# Exit with an error otherwise.
# See https://stackoverflow.com/questions/10858261/abort-makefile-if-variable-not-set
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
        $(error Undefined $1$(if $2, ($2))))

vars:
	@echo "\n\
  HASH                               $(HASH)\n\
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
  vars                 Display all Makester global variable values\n\
  print-<var>          Display the Makefile global variable '<var>' value\n\
  clean                Remove all files not tracked by Git\n\
  submodule-update     Update your existing Git submodules\n"

.PHONY: vars makester-help
