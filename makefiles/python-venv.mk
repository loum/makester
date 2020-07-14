# Check if we have python3 available.
PY3_VERSION := $(shell python3 --version 2>/dev/null)
PY3_VERSION_FULL := $(wordlist 2, 4, $(subst ., , ${PY3_VERSION}))
PY3_VERSION_MAJOR := $(word 1, ${PY3_VERSION_FULL})
PY3_VERSION_MINOR := $(word 2, ${PY3_VERSION_FULL})
PY3_VERSION_PATCH := $(word 3, ${PY3_VERSION_FULL})

# python3.3 introduced the venv module which is the
# preferred method for creating python3 virtual envs.
# Otherwise, python3 defaults to pyvenv
USE_PYVENV := $(shell [ ${PY3_VERSION_MINOR} -ge 3 ] && echo 0 || echo 1)
ifneq ($(PY3_VERSION),)
  PY3 := $(shell which python3 2>/dev/null)
  ifeq ($(USE_PYVENV), 1)
    PY_VENV := pyvenv-${PY3_VERSION_MAJOR}.${PY3_VERSION_MINOR}
  else
    PY_VENV := ${PY3} -m venv
  endif
endif

# As long as pip has been installed system-wide, we can use virtualenv
# for python2.
PY2_VENV := $(shell which virtualenv 2>/dev/null)

# Determine virtual env tool to use.
ifeq ($(PYVERSION), 2)
  VENV_TOOL := ${PY2_VENV}
else
  VENV_TOOL := ${PY_VENV}
  PYVERSION := 3
endif

# OK, set some globals.
WHEEL=~/wheelhouse
PYTHONPATH=.
PIP := $(PYVERSION)env/bin/pip
PYTHON := $(PYVERSION)env/bin/python

VENV_DIR_EXISTS := $(shell [ -e "${PYVERSION}env" ] && echo 1 || echo 0)
clear-env:
ifeq ($(VENV_DIR_EXISTS), 1)
	@echo \#\#\# Deleting existing environment ${PYVERSION}env ...
	$(shell which rm) -fr ${PYVERSION}env
	@echo \#\#\# ${PYVERSION}env delete done.
endif

init-env:
	@echo \#\#\# Creating virtual environment ${PYVERSION}env ...
	@echo \#\#\# Using wheel house $(WHEEL) ...
ifneq ($(VENV_TOOL),)
	$(VENV_TOOL) ${PYVERSION}env
	@echo \#\#\# ${PYVERSION}env build done.

	@echo \#\#\# Preparing wheel environment and directory ...
	$(shell which mkdir) -pv $(WHEEL) 2>/dev/null
	$(PIP) install --upgrade pip
	$(PIP) install --upgrade setuptools
	$(PIP) install wheel
	@echo \#\#\# wheel env done.

	@echo \#\#\# Installing package dependencies ...
	$(PIP) wheel --wheel-dir $(WHEEL) --find-links=$(WHEEL) $(PIP_INSTALL)
	$(PIP) install --find-links=$(WHEEL) $(PIP_INSTALL)
	@echo \#\#\# Package install done.
else
	@echo \#\#\# Hmmm, cannot find virtual env tool.
	@echo \#\#\# Virtual environment not created.
endif

PIP_REQUIREMENTS := $(shell [ -f ./requirements.txt ] && echo --requirement requirements.txt)
pip-requirements: PIP_INSTALL = $(PIP_REQUIREMENTS)
pip-requirements: init-env

MAKESTER_REQUIREMENTS = --requirement makester/requirements.txt
makester-requirements: PIP_INSTALL = $(MAKESTER_REQUIREMENTS)
makester-requirements: init-env

MAKESTER_REQUIREMENTS = --requirement makester/azure-requirements.txt
azure-requirements: PIP_INSTALL = $(MAKESTER_REQUIREMENTS)
azure-requirements: init-env

pip-editable: PIP_INSTALL = -e .
pip-editable: init-env

package:
	@echo \#\#\# Building package ...
	$(PYVERSION)env/bin/python setup.py bdist_wheel -d $(WHEEL)
	@echo \#\#\# Build done.

py-versions:
	@echo python3 version: ${PY3_VERSION}
	@echo python3 minor: ${PY3_VERSION_MINOR}
	@echo path to python3 executable: ${PY3}
	@echo python3 virtual env command: ${PY_VENV}
	@echo python2 virtual env command: ${PY2_VENV}
	@echo virtual env tooling: ${VENV_TOOL}

help: python-venv-help

python-venv-help:
	@echo "(makefiles/python-venv.mk)\n\
  py-versions          Display your environment Python setup\n\
  pip-requirements     \"clear-env\"|\"init-env\" and build virtual environment deps from \"requirements.txt\"\n\
  pip-editable         \"clear-env\"|\"init-env\" and build virtual environment deps from \"setup.py\"\n\
  package              Build python package from \"setup.py\" and write to \"--wheel-dir\" (defaults to ~/wheelhouse)\n\
  clear-env            Remove virtual environment \"$(PYVERSION)env\"\n\
  init-env             Build virtual environment \"$(PYVERSION)env\"\n"

.PHONY: help package
