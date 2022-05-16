ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := versioning-help
endif

GITVERSION_VERSION := latest

# PACKAGE_NAME simulates PyPI package naming convention (replacing hyphens with underscores).
MAKESTER__PACKAGE_NAME := $(shell echo $(MAKESTER__PROJECT_NAME) | tr - _)

CMD ?= /h
# GitVersion help (default).
gitversion:
	-@$(shell which mkdir) -p .makester
	@$(DOCKER) run --rm\
 -v "$(MAKESTER__PROJECT_DIR):/$(MAKESTER__PACKAGE_NAME)"\
 gittools/gitversion:$(GITVERSION_VERSION) $(CMD) > .makester/versioning

# GitVersion executable's version.
gitversion-version: CMD = /version

# GitVersion version variables.
GITVERSION_CONFIG ?= GitVersion.yml
gitversion-versions: CMD =  /$(MAKESTER__PACKAGE_NAME) /config $(GITVERSION_CONFIG)

gitversion-version gitversion-long gitversion-versions: gitversion

GITVERSION_VARIABLE ?= AssemblySemFileVer
release-version: gitversion-versions
	$(info ### Filtering GitVersion variable: $(GITVERSION_VARIABLE))
	$(eval $(shell echo export MAKESTER__RELEASE_VERSION=$(shell sed -e 's/=.*$$// p' .makester/versioning | jq .$(GITVERSION_VARIABLE))))
	$(info ### MAKESTER__RELEASE_VERSION: $(MAKESTER__RELEASE_VERSION))

versioning-help:
	@echo "(makefiles/versioning.mk)\n\
  gitversion           GitVersion usage message\n\
  gitversion-versions  GitVersion version\n\
  release-version      Filtered GitVersion variables (default: \"GITVERSION_VARIABLE\"=\"AssemblySemFileVer\")\n"

.PHONY: versioning-help
