ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := versioning-help
endif

ifndef MAKESTER__PRIMED
$(info ### Add the following include statement to your Makefile)
$(info include makester/makefiles/makester.mk)
$(error ### missing include dependency)
endif

# Defaults.
MAKESTER__GITVERSION_CONFIG ?= makester/resources/sample/GitVersion.yml
MAKESTER__GITVERSION_VARIABLE ?= AssemblySemFileVer
ifndef MAKESTER__GITVERSION_VERSION
  ifeq ($(MAKESTER__ARCH), arm64)
    MAKESTER__GITVERSION_VERSION ?= 5.12.0-ubuntu.20.04-6.0-arm64
  else 
    MAKESTER__GITVERSION_VERSION ?= 5.12.0-alpine.3.14-6.0
  endif
endif

_dump_versioning:
	$(shell which cat) $(MAKESTER__WORK_DIR)/versioning

# Run GitVersion.
#
# Params:
#   1. GitVersion sub-command.
define _gitversion-cmd
	$(MAKE) makester-work-dir
	$(call _gitversion-exe,$(value 1))
endef

define _gitversion-exe
	@$(MAKESTER__DOCKER) run --rm -v "$(MAKESTER__GIT_DIR):/$(MAKESTER__PROJECT_NAME)"\
 gittools/gitversion:$(MAKESTER__GITVERSION_VERSION) $(1)
endef

# GitVersion help (default).
gitversion:
	$(call _gitversion-cmd,/h)
	$(MAKE) _dump_versioning

# GitVersion executable's version.
gitversion-version:
	$(info ### Current GitVersion version ...)
	$(call _gitversion-cmd,/version)

# GitVersion version variables.
_gitversion-versions:
	$(call _gitversion-cmd,/$(MAKESTER__PROJECT_NAME) /config $(MAKESTER__GITVERSION_CONFIG)) > $(MAKESTER__WORK_DIR)/versioning

# GitVersion raw output.
gitversion-debug:
	$(call _gitversion-cmd,/$(MAKESTER__PROJECT_NAME) /config $(MAKESTER__GITVERSION_CONFIG))

_gitversion-versions-rm: MAKESTER__WORK_DIR := $(MAKESTER__WORK_DIR)
_gitversion-versions-rm:
	$(info ### Removing $(MAKESTER__WORK_DIR)/versioning)
	$(shell rm $(MAKESTER__WORK_DIR)/versioning 2>/dev/null)

# Symbol to be deprecated in Makester 0.3.0
release-version: _release-version-warn gitversion-release
_release-version-warn:
	$(call deprecated,release-version,0.3.0,gitversion-release)

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
	printf "\n($(MAKESTER__MAKEFILES)/versioning.mk)\n"
	$(call help-line,gitversion,GitVersion usage message)
	$(call help-line,gitversion-clear,Clear the temporary GitVersion working files under \"$(MAKESTER__WORK_DIR)\")
	$(call help-line,gitversion-debug,Display the GitVersion project release values unfiltered)
	$(call help-line,gitversion-release,GitVersion \"$(MAKESTER__GITVERSION_VARIABLE)\" to $(MAKESTER__VERSION_FILE))
	$(call help-line,gitversion-release-ro,Read-only dump of GitVersion \"$(MAKESTER__GITVERSION_VARIABLE)\")
	$(call help-line,gitversion-version,The actual GitVersion version)

.PHONY: versioning-help
