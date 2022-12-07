ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := python-venv-help
endif

ifndef MAKESTER__PRIMED
$(info ### Add the following include statement to your Makefile)
$(info include makester/makefiles/makester.mk)
$(error ### missing include dependency)
endif

# Set PYTHONPATH as per "src layout". See https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/
export PYTHONPATH ?= src

_PYTHON3 ?= $(call check-exe,python3,https://github.com/pyenv/pyenv)

# Check if we have python3 available.
PY3_VERSION ?= $(shell $(_PYTHON3) --version 2>/dev/null)
PY3_VERSION_FULL ?= $(wordlist 2, 4, $(subst ., , $(PY3_VERSION)))
PY3_VERSION_MAJOR ?= $(word 1, $(PY3_VERSION_FULL))
PY3_VERSION_MINOR ?= $(word 2, $(PY3_VERSION_FULL))
PY3_VERSION_PATCH ?= $(word 3, $(PY3_VERSION_FULL))

# python3.3 introduced the venv module which is the
# preferred method for creating python3 virtual envs.
# Otherwise, python3 defaults to pyvenv
_USE_PYVENV := $(shell [ $(PY3_VERSION_MINOR) -ge 3 ] && echo 0 || echo 1)
ifneq ($(PY3_VERSION),)
  ifeq ($(_USE_PYVENV),1)
    PY_VENV := pyvenv-$(PY3_VERSION_MAJOR).$(PY3_VERSION_MINOR)
  else
    PY_VENV := $(_PYTHON3) -m venv
  endif
endif

# As long as pip has been installed system-wide, we can use virtualenv
# for python2.
PY2_VENV := $(shell which virtualenv 2>/dev/null)

# Determine virtual env tool to use.
ifeq ($(PWD)/$(PYVERSION), 2)
  VENV_TOOL := $(PY2_VENV)
else
  VENV_TOOL := $(PY_VENV)
  PYVERSION := 3
endif

# OK, set some globals.
MAKESTER__WHEEL ?= ~/wheelhouse
MAKESTER__PIP ?= $(PWD)/$(PYVERSION)env/bin/pip
MAKESTER__PYTHON ?= $(PWD)/$(PYVERSION)env/bin/python

# Symbols to be deprecated in Makester 0.2.0
PIP ?= $(call deprecated,PIP,0.2.0,MAKESTER__PIP)
PYTHON ?= $(call deprecated,PYTHON,0.2.0,MAKESTER__PYTHON)
WHEEL ?= $(call deprecated,WHEEL,0.2.0,MAKESTER__WHEEL)

_VENV_DIR_EXISTS := $(shell [ -e "$(PWD)/$(PYVERSION)env" ] && echo 1 || echo 0)
clear-env:
ifeq ($(_VENV_DIR_EXISTS), 1)
	$(info ### Deleting existing environment $(PWD)/$(PYVERSION)env ...)
	$(shell which rm) -fr $(PWD)/$(PYVERSION)env
endif

init-env: wheel-dir
	$(info ### Creating virtual environment $(PWD)/$(PYVERSION)env ...)
ifneq ($(VENV_TOOL),)
	$(VENV_TOOL) $(PWD)/$(PYVERSION)env

	$(info ### Preparing pip and setuptools ...)
	$(MAKESTER__PIP) install --upgrade pip setuptools wheel

	$(info ### Installing ...)
	$(MAKESTER__PIP) install --find-links=$(MAKESTER__WHEEL) $(PIP_INSTALL)
else
	$(warn ### Hmmm, cannot find virtual env tool)
	$(warn ### Virtual environment not created)
endif

wheel-dir:
	$(info ### Creating Wheel directory "$(MAKESTER__WHEEL)"...)
	$(shell which mkdir) -pv $(MAKESTER__WHEEL)

wheel: wheel-dir
	$(info ### Build Wheel archives for your requirements and dependencies ...)
	$(MAKESTER__PIP) wheel --wheel-dir $(MAKESTER__WHEEL) --find-links=$(MAKESTER__WHEEL) $(PIP_INSTALL)

PIP_REQUIREMENTS := $(shell [ -f ./requirements.txt ] && echo --requirement requirements.txt)
pip-requirements: PIP_INSTALL = $(PIP_REQUIREMENTS)
pip-requirements: init-env

makester-requirements: PIP_INSTALL = --requirement makester/requirements.txt
makester-requirements: init-env

pip-editable: PIP_INSTALL = -e .
pip-editable: init-env

SETUP_PY := $(PWD)/setup.py
package-clean:
	$(info ### Cleaning PyPI package temporary directories ...)
	$(MAKESTER__PYTHON) $(SETUP_PY) clean

package: package-clean
	$(info ### Building package ...)
	$(MAKESTER__PYTHON) $(SETUP_PY) bdist_wheel --dist-dir $(MAKESTER__WHEEL) --verbose

py-versions:
	$(info ### python3 version: $(PY3_VERSION))
	$(info ### python3 minor: $(PY3_VERSION_MINOR))
	$(info ### path to system python3 executable: $(PY3))
	$(info ### python3 virtual env command: $(PY_VENV))
	$(info ### python2 virtual env command: $(PY2_VENV))
	$(info ### virtual env tooling: $(VENV_TOOL))

py:
	-@$(MAKESTER__PYTHON)

python-venv-help:
	@echo "(makefiles/python-venv.mk)\n\
  py-versions          Display your environment Python setup\n\
  pip-requirements     \"clear-env\"|\"init-env\" and build virtual environment deps from \"requirements.txt\"\n\
  pip-editable         \"clear-env\"|\"init-env\" and build virtual environment deps from \"setup.py\"\n\
  package              Build python package from \"setup.py\" and write to \"--wheel-dir\" (defaults to ~/wheelhouse)\n\
  clear-env            Remove virtual environment \"$(PWD)/$(PYVERSION)env\"\n\
  init-env             Build virtual environment \"$(PWD)/$(PYVERSION)env\"\n\
  py                   Start the vitual environment Python REPL\n"

.PHONY: python-venv-help package
