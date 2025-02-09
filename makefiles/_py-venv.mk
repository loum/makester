ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := _py-venv-help
endif

# python3.3 introduced the venv module which is the
# preferred method for creating python3 virtual envs.
# Otherwise, python3 defaults to pyvenv
_USE_PYVENV := $(shell [ $(_PY3_VERSION_MINOR) -ge 3 ] && echo 0 || echo 1)
ifndef MAKESTER__VENV_TOOL
  ifeq ($(_USE_PYVENV),1)
    MAKESTER__VENV_TOOL ?= pyvenv-$(_PY3_VERSION_MAJOR).$(_PY3_VERSION_MINOR)
  else
    MAKESTER__VENV_TOOL ?= $(MAKESTER__SYSTEM_PYTHON3) -m venv
  endif
endif

# OK, set some globals.
ifeq ($(strip $(MAKESTER__PROJECT_NAME)),makester)
  MAKESTER__PIP ?= $(MAKESTER__BIN)/pip
  MAKESTER__PYTHON ?= $(MAKESTER__BIN)/python
else
  MAKESTER__PIP ?= $(MAKESTER__VENV_HOME)/bin/pip
  MAKESTER__PYTHON ?= $(MAKESTER__VENV_HOME)/bin/python
endif

_VENV_DIR_EXISTS ?= $(shell [ -e "$(MAKESTER__VENV_HOME)" ] && echo 1 || echo 0)
py-venv-clear:
ifeq ($(_VENV_DIR_EXISTS), 1)
	$(info ### Deleting virtual environment $(MAKESTER__VENV_HOME) ...)
	$(shell which rm) -fr $(MAKESTER__VENV_HOME)
endif

py-venv-init: wheel-dir py-venv-create

MAKESTER__VENV_HOME ?= $(MAKESTER__PROJECT_DIR)/venv
py-venv-create:
	$(info ### Creating virtual environment $(MAKESTER__VENV_HOME) ...)
ifneq ($(MAKESTER__VENV_TOOL),)
	$(MAKESTER__VENV_TOOL) $(MAKESTER__VENV_HOME)
	$(info ### Preparing pip and setuptools ...)
	$(MAKESTER__PIP) install --upgrade pip setuptools wheel
else
	$(warn ### Hmmm, cannot find virtual env tool)
	$(warn ### Virtual environment not created)
endif

wheel-dir:
	$(info ### Creating Wheel directory "$(MAKESTER__WHEEL)"...)
	$(shell which mkdir) -pv $(MAKESTER__WHEEL)

wheel: wheel-dir
	$(info ### Build Wheel archives for your requirements and dependencies ...)
	$(MAKESTER__PIP) wheel --wheel-dir $(MAKESTER__WHEEL) --find-links=$(MAKESTER__WHEEL) $(MAKESTER__PIP_INSTALL)

PIP_REQUIREMENTS := $(shell [ -f ./requirements.txt ] && echo --requirement requirements.txt)
pip-requirements: MAKESTER__PIP_INSTALL := $(PIP_REQUIREMENTS)
pip-requirements: py-install

makester-requirements: MAKESTER__PIP_INSTALL := --requirement makester/requirements.txt
makester-requirements: py-install

pip-editable: py-install

SETUP_PY := $(MAKESTER__PROJECT_DIR)/setup.py
py-package-clean:
	$(info ### Cleaning PyPI package temporary directories ...)
	$(MAKESTER__PYTHON) $(SETUP_PY) clean

py-package: py-package-clean
	$(info ### Building package ...)
	$(MAKESTER__PYTHON) $(SETUP_PY) bdist_wheel --dist-dir $(MAKESTER__WHEEL) --verbose

py-venv-vars:
	printf -- "-%.0s" {1..10}; printf "\n"
	$(call help-line,Virtual env tooling:,$(MAKESTER__VENV_TOOL))
	$(call help-line,Virtual env Python:,$(MAKESTER__PYTHON))
	$(call help-line,Virtual env pip:,$(MAKESTER__PIP))

py-venv-repl py:
	-@$(MAKESTER__PYTHON)

_py-venv-help:
	printf -- "-%.0s" {1..10}; printf "\n"
	$(call help-line,pip-editable,Build virtual environment deps from \"setup.py\")
	$(call help-line,pip-requirements,Build virtual environment deps from \"requirements.txt\")
	$(call help-line,py-package,Build python package from \"setup.py\" and write to \"--wheel-dir\" (defaults to ~/wheelhouse))
	$(call help-line,py-package-clean,Clear Python package artifacts)
	$(call help-line,py-venv-clear,Delete virtual environment \"$(MAKESTER__VENV_HOME)\")
	$(call help-line,py-venv-init,Build virtual environment \"$(MAKESTER__VENV_HOME)\")
	$(call help-line,py-venv-repl,Start the vitual environment Python REPL)
	$(call help-line,py-venv-vars,Display your environment Python setup)

.PHONY: py-package
