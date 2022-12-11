.SILENT:
.DEFAULT_GOAL := help

MAKESTER__PROJECT_NAME := makester
MAKESTER__GITVERSION_CONFIG := sample/GitVersion.yml

include makefiles/makester.mk
include makefiles/docs.mk
include makefiles/docker.mk
include makefiles/py.mk
include makefiles/versioning.mk

init: release-version py-venv-clear py-venv-init py-install

TESTS_TO_RUN := $(if $(TESTS),$(TESTS),tests)
tests:
	tests/bats/bin/bats $(TESTS_TO_RUN)

help: makester-help docs-help docker-help versioning-help py-help
	@echo "(simple/Makefile)\n\
  init                 Build Makester environment\n\
  tests                Run code test suite\n"

.PHONY: tests
