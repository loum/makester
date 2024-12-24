.SILENT:
.DEFAULT_GOAL := help

# Use a single bash shell for each job, and immediately exit on failure
SHELL := zsh
.SHELLFLAGS := -ceu
.ONESHELL:

#
# Makester overrides.
#
MAKESTER__STANDALONE := true

include $(HOME)/.makester/makefiles/makester.mk

MAKESTER__PROJECT_NAME := makester
MAKESTER__GITVERSION_CONFIG := GitVersion.yml
MAKESTER__VERSION_FILE := $(MAKESTER__PYTHON_PROJECT_ROOT)/VERSION

init: py-venv-clear py-venv-init py-install

TESTS_TO_RUN := $(if $(TESTS),$(TESTS),tests)
tests:
	tests/bats/bin/bats $(TESTS_TO_RUN)

help: makester-help
	$(call makefile-help-header)
	$(call help-line,init,Build Makester environment)
	$(call help-line,tests,Run code test suite)

.PHONY: tests
