ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := versioning-help
endif

ifndef MAKESTER__PRIMED
$(info ### Add the following include statement to your Makefile)
$(info include makester/makefiles/makester.mk)
$(error ### missing include dependency)
endif

# Defaults.
MAKESTER__GITVERSION_CONFIG ?= makester/sample/GitVersion.yml
MAKESTER__GITVERSION_VARIABLE ?= AssemblySemFileVer
ifndef MAKESTER__GITVERSION_VERSION
  ifeq ($(MAKESTER__ARCH), arm64)
    MAKESTER__GITVERSION_VERSION ?= 5.11.1-ubuntu.20.04-6.0-arm64
  else 
    MAKESTER__GITVERSION_VERSION ?= 5.11.1-alpine.3.13-6.0
  endif
endif

_dump_versioning:
	$(shell which cat) $(MAKESTER__WORK_DIR)/versioning

# GitVersion help (default).
CMD ?= /h
_gitversion-cmd: makester-work-dir
	@$(MAKESTER__DOCKER) run --rm\
 -v "$(MAKESTER__GIT_DIR):/$(MAKESTER__PROJECT_NAME)"\
 gittools/gitversion:$(MAKESTER__GITVERSION_VERSION) $(CMD) > $(MAKESTER__WORK_DIR)/versioning 2>/dev/null

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
	$(info ### Removing $(MAKESTER__WORK_DIR)/versioning)
	$(shell rm $(MAKESTER__WORK_DIR)/versioning 2>/dev/null)

# Symbol to be deprecated in Makester 0.3.0
release-version: _release-version-warn gitversion-release
_release-version-warn:
	$(call deprecated,release-version,0.3.0,gitversion-release)

MAKESTER__VERSION_FILE ?= $(MAKESTER__WORK_DIR)/VERSION

_GITVERSION_FILTER := sed -e 's/=.*$$// p' $(MAKESTER__WORK_DIR)/versioning | jq .$(MAKESTER__GITVERSION_VARIABLE) | tr -d '"'

_gitversion-release-msg:
	$(info ### Filtering GitVersion variable: $(MAKESTER__GITVERSION_VARIABLE))

gitversion-release: _gitversion-release-msg _gitversion-versions-rm _gitversion-versions
	$(info ### MAKESTER__RELEASE_VERSION: $(shell $(_GITVERSION_FILTER) | tee $(MAKESTER__VERSION_FILE)))

gitversion-release-ro: _gitversion-release-msg _gitversion-versions-rm _gitversion-versions
	$(info ### MAKESTER__RELEASE_VERSION: $(shell $(_GITVERSION_FILTER)))

_gitversion-release-rm:
	$(info ### Removing $(MAKESTER__VERSION_FILE))
	$(shell rm $(MAKESTER__VERSION_FILE) 2>/dev/null)

gitversion-clear: _gitversion-release-rm _gitversion-versions-rm

versioning-help:
	@echo "(makefiles/versioning.mk)\n\
  gitversion           GitVersion usage message\n\
  gitversion-clear     Clear the temporary GitVersion working files under \"$(MAKESTER__WORK_DIR)\"\n\
  gitversion-release   GitVersion \"$(MAKESTER__GITVERSION_VARIABLE)\" to $(MAKESTER__VERSION_FILE)\n\
  gitversion-release-ro\n\
                       Read-only dump of GitVersion \"$(MAKESTER__GITVERSION_VARIABLE)\"\n\
  gitversion-version   The actual GitVersion version\n"

.PHONY: versioning-help
