ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := versioning-help
endif

ifndef MAKESTER__DOCKER
$(info ### Add the following include statement to your Makefile)
$(info include makester/makefiles/docker.mk)
$(error ### missing include dependency)
endif

# Defaults.
ifndef MAKESTER__GITVERSION_CONFIG
  MAKESTER__GITVERSION_CONFIG := makester/sample/GitVersion.yml
endif
MAKESTER__GITVERSION_VARIABLE ?= AssemblySemFileVer
MAKESTER__GITVERSION_VERSION ?= latest

_dump_versioning:
	$(shell which cat) $(MAKESTER__WORK_DIR)/versioning

# GitVersion help (default).
CMD ?= /h
_gitversion-cmd: MAKESTER__WORK_DIR := $(MAKESTER__WORK_DIR)
_gitversion-cmd: MAKESTER__GITVERSION_CONFIG := $(MAKESTER__GITVERSION_CONFIG)
_gitversion-cmd: makester-work-dir
	@$(MAKESTER__DOCKER) run --rm\
 -v "$(MAKESTER__PROJECT_DIR):/$(MAKESTER__PROJECT_NAME)"\
 gittools/gitversion:$(MAKESTER__GITVERSION_VERSION) $(CMD) > $(MAKESTER__WORK_DIR)/versioning

gitversion: _gitversion-cmd _dump_versioning

# GitVersion executable's version.
gitversion-version: _gitversion-version-msg _gitversion-version _dump_versioning
_gitversion-version-msg:
	$(info ### Current GitVersion version ...)
_gitversion-version: CMD := /version

# GitVersion version variables.
_gitversion-versions: CMD = /$(MAKESTER__PROJECT_NAME) /config $(MAKESTER__GITVERSION_CONFIG)

_gitversion-version _gitversion-versions: _gitversion-cmd

_gitversion-versions-rm: MAKESTER__WORK_DIR := $(MAKESTER__WORK_DIR)
_gitversion-versions-rm:
	-@$(info ### removing $(MAKESTER__WORK_DIR)/versioning $(shell rm $(MAKESTER__WORK_DIR)/versioning))

MAKESTER__VERSION_FILE ?= $(MAKESTER__WORK_DIR)/VERSION

# Symbol to be deprecated in Makester 0.3.0
release-version: _release-version-warn gitversion-release
_release-version-warn:
	$(call deprecated,release-version,0.3.0,gitversion-release)

gitversion-release: MAKESTER__WORK_DIR := $(MAKESTER__WORK_DIR)
gitversion-release: _gitversion-versions
	$(info ### Filtering GitVersion variable: $(MAKESTER__GITVERSION_VARIABLE))
	$(shell sed -e 's/=.*$$// p' $(MAKESTER__WORK_DIR)/versioning | jq .$(MAKESTER__GITVERSION_VARIABLE) | tr -d '"' > $(MAKESTER__VERSION_FILE))
	$(info ### MAKESTER__RELEASE_VERSION: $(shell cat $(MAKESTER__VERSION_FILE)))

_gitversion-release-rm:
	-@$(info ### removing $(MAKESTER__VERSION_FILE) $(shell rm $(MAKESTER__VERSION_FILE)))

gitversion-clear: _gitversion-release-rm _gitversion-versions-rm

versioning-help:
	@echo "(makefiles/versioning.mk)\n\
  gitversion           GitVersion usage message\n\
  gitversion-clear     Clear the temporary GitVersion working files under \"$(MAKESTER__WORK_DIR)\"\n\
  gitversion-release   Filtered GitVersion variables against \"$(MAKESTER__GITVERSION_VARIABLE)\"\n\
  gitversion-version   The actual GitVersion version\n"

.PHONY: versioning-help
