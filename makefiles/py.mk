ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := py-help
endif

ifndef MAKESTER__PRIMED
$(info ### Add the following include statement to your Makefile)
$(info include makester/makefiles/makester.mk)
$(error ### missing include dependency)
endif

# Set PYTHONPATH as per "src layout". See https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/
export PYTHONPATH ?= src

# As Makester sees the system Python.
MAKESTER__SYSTEM_PYTHON3 ?= $(call check-exe,python3,https://github.com/pyenv/pyenv)

# Check if we have python3 available.
ifneq (,$(wildcard $(MAKESTER__SYSTEM_PYTHON3)))
  MAKESTER__PY3_VERSION ?= $(shell $(MAKESTER__SYSTEM_PYTHON3) --version)
  _PY3_VERSION_FULL ?= $(wordlist 2, 4, $(subst ., ,$(MAKESTER__PY3_VERSION)))
  _PY3_VERSION_MAJOR ?= $(word 1, $(_PY3_VERSION_FULL))
  _PY3_VERSION_MINOR ?= $(word 2, $(_PY3_VERSION_FULL))
  _PY3_VERSION_PATCH ?= $(word 3, $(_PY3_VERSION_FULL))
else
  $(error ### No Python executable found: Check your MAKESTER__SYSTEM_PYTHON3=$(MAKESTER__SYSTEM_PYTHON3) setting)
endif

# Python defaults.
MAKESTER__WHEEL ?= ~/wheelhouse

ifndef MAKESTER__PIP_INSTALL
  MAKESTER__PIP_INSTALL := -e .
endif

py-install:
	$(info ### Installing project dependencies into $(MAKESTER__VENV_HOME) ...)
	$(MAKESTER__PIP) install --find-links=$(MAKESTER__WHEEL) $(MAKESTER__PIP_INSTALL)

py-install-makester: MAKESTER__PIP_INSTALL := -e makester
py-install-makester: py-venv-clear py-venv-init py-install

# Private Makefile includes that leverage capabilities in this Makefile.
include makefiles/_py-venv.mk

py-vars: _py-vars py-venv-vars
_py-vars: 
	$(info ### System python3: $(MAKESTER__SYSTEM_PYTHON3))
	$(info ### System python3 version: $(MAKESTER__PY3_VERSION))

py-help: _py-help _py-venv-help

_py-help:
	@echo "(makefiles/py.mk)\n\
  py-vars              Display system Python settings\n\
  py-install           Install Python project package dependencies"
