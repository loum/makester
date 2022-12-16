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

MAKESTER__PIP_INSTALL ?= -e .

py-install:
	$(info ### Installing project dependencies into $(MAKESTER__VENV_HOME) ...)
	$(MAKESTER__PIP) install --find-links=$(MAKESTER__WHEEL) $(MAKESTER__PIP_INSTALL)

MAKESTER__PIP_INSTALL_EXTRAS ?= dev
py-install-extras: MAKESTER__PIP_INSTALL := -e .[$(MAKESTER__PIP_INSTALL_EXTRAS)]
py-install-extras: py-install

py-install-makester: MAKESTER__PIP_INSTALL := -e makester
py-install-makester: MAKESTER__WORK_DIR := $(PWD)/makester/.makester
py-install-makester: MAKESTER__VERSION_FILE := makester/src/makester/VERSION
py-install-makester: MAKESTER__PROJECT_NAME := makester
py-install-makester: MAKESTER__GIT_DIR := $(PWD)/.git/modules/makester
py-install-makester: MAKESTER__GITVERSION_CONFIG := $(PWD)/makester/sample/GitVersion.yml
py-install-makester: py-install

MAKESTER__PYTHON_PROJECT_ROOT ?= $(MAKESTER__PROJECT_DIR)/src/$(MAKESTER__PACKAGE_NAME)

py-project-create: makester-gitignore makester-mit-license
	$(info ### Creating a Python project directory structure under $(MAKESTER__PYTHON_PROJECT_ROOT))
	@$(shell which mkdir) -pv $(MAKESTER__PYTHON_PROJECT_ROOT)
	@$(shell which touch) $(MAKESTER__PYTHON_PROJECT_ROOT)/__init__.py
	@$(shell which mkdir) -pv $(MAKESTER__PROJECT_DIR)/tests/$(MAKESTER__PACKAGE_NAME)
	@$(shell which cp) $(MAKESTER__RESOURCES_DIR)/blank_directory.gitignore $(MAKESTER__PROJECT_DIR)/tests/$(MAKESTER__PACKAGE_NAME)/.gitignore
	@$(shell which cp) $(MAKESTER__RESOURCES_DIR)/pyproject.toml $(MAKESTER__PROJECT_DIR)

MAKESTER__PYLINT_RCFILE ?= $(MAKESTER__PROJECT_DIR)/pylintrc
py-pylintrc:
	$(info ### Generating project pylint configuration to $(MAKESTER__PYLINT_RCFILE) ...)
	@pylint --generate-rcfile > $(MAKESTER__PYLINT_RCFILE)

py-deps:
	$(info ### Displaying "$(MAKESTER__PACKAGE_NAME)" package dependencies ...)
	@pipdeptree

# Private Makefile includes that leverage capabilities in this Makefile.
include $(MAKESTER__MAKEFILES)/_py-venv.mk

py-distribution:
	$(MAKESTER__PYTHON) -m build

py-vars: _py-vars py-venv-vars
_py-vars: 
	$(info ### System python3: $(MAKESTER__SYSTEM_PYTHON3))
	$(info ### System python3 version: $(MAKESTER__PY3_VERSION))

py-help: _py-help _py-venv-help

_py-help:
	@echo "(makefiles/py.mk)\n\
  py-dep           	   Display Python package dependencies for \"$(MAKESTER__PACKAGE_NAME)\"\n\
  py-distribution      Create a versioned archive file that contains your Python project's packages\n\
  py-install           Install Python project package dependencies\n\
  py-project-create    Create a minimal Python project directory structure scaffolding\n\
  py-vars              Display system Python settings\n"
