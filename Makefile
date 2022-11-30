.SILENT:
.DEFAULT_GOAL := help

MAKESTER__PROJECT_NAME := makester
MAKESTER__GITVERSION_CONFIG := sample/GitVersion.yml

include makefiles/makester.mk
include makefiles/docker.mk
include makefiles/python-venv.mk
include makefiles/versioning.mk

init: pip-requirements

TESTS_TO_RUN := $(if $(TESTS),$(TESTS),tests)
tests:
	tests/bats/bin/bats $(TESTS_TO_RUN)

help: makester-help docker-help versioning-help python-venv-help
	@echo "(simple/Makefile)\n\
  init                 Build Makester environment\n\
  tests                Run code test suite\n"

.PHONY: tests
