.SILENT:
.DEFAULT_GOAL := help

MAKESTER__PROJECT_NAME := makester
MAKESTER__GITVERSION_CONFIG := resources/sample/GitVersion.yml

include makefiles/makester.mk

#
# Makester overrides.
#
MAKESTER__GITVERSION_CONFIG := GitVersion.yml
MAKESTER__VERSION_FILE := $(MAKESTER__PYTHON_PROJECT_ROOT)/VERSION

init: py-venv-clear py-venv-init py-install

TESTS_TO_RUN := $(if $(TESTS),$(TESTS),tests)
tests:
	tests/bats/bin/bats $(TESTS_TO_RUN)

MAKESTER__RESOURCES_DIR := $(MAKESTER__PROJECT_DIR)/resources

help: makester-help
	@echo "(simple/Makefile)\n\
  init                 Build Makester environment\n\
  tests                Run code test suite\n"

.PHONY: tests
