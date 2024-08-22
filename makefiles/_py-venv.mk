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
ifeq ($(strip $(MAKESTER__STANDALONE)),true)
  MAKESTER__PIP ?= $(MAKESTER__BIN)/pip
  MAKESTER__PYTHON ?= $(MAKESTER__BIN)/python
else
  MAKESTER__PIP ?= $(MAKESTER__PROJECT_DIR)/venv/bin/pip
  MAKESTER__PYTHON ?= $(MAKESTER__PROJECT_DIR)/venv/bin/python
endif

# Symbol to be deprecated in Makester 0.3.0
clear-env: _clear-env-warn py-venv-clear
_clear-env-warn:
	$(call deprecated,clear-env,0.3.0,py-venv-clear)

_VENV_DIR_EXISTS ?= $(shell [ -e "$(MAKESTER__PROJECT_DIR)/venv" ] && echo 1 || echo 0)
py-venv-clear:
ifeq ($(_VENV_DIR_EXISTS), 1)
	$(info ### Deleting virtual environment $(MAKESTER__PROJECT_DIR)/venv ...)
	$(shell which rm) -fr $(MAKESTER__PROJECT_DIR)/venv
endif

# Symbol to be deprecated in Makester 0.3.0
init-env: _init-env-warn py-venv-init
_init-env-warn:
	$(call deprecated,init-env,0.3.0,py-venv-init)

py-venv-init: wheel-dir py-venv-create

MAKESTER__VENV_HOME ?= $(MAKESTER__PROJECT_DIR)/venv
py-venv-create:
	$(info ### Creating virtual environment $(MAKESTER__PROJECT_DIR)/venv ...)
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
package-clean:
	$(info ### Cleaning PyPI package temporary directories ...)
	$(MAKESTER__PYTHON) $(SETUP_PY) clean

package: package-clean
	$(info ### Building package ...)
	$(MAKESTER__PYTHON) $(SETUP_PY) bdist_wheel --dist-dir $(MAKESTER__WHEEL) --verbose

# Symbol to be deprecated in Makester 0.3.0
py-versions: _py-versions-warn py-venv-vars
_py-versions-warn:
	$(call deprecated,py-versions,0.3.0,py-venv-vars)

py-venv-vars:
	$(info ### ---)
	$(info ### Virtual env tooling: $(MAKESTER__VENV_TOOL))
	$(info ### Virtual env Python: $(MAKESTER__PYTHON))
	$(info ### Virtual env pip: $(MAKESTER__PIP))

py-venv-repl py:
	-@$(MAKESTER__PYTHON)

_py-venv-help:
	@echo "  ---\n\
  package              Build python package from \"setup.py\" and write to \"--wheel-dir\" (defaults to ~/wheelhouse)\n\
  pip-editable         Build virtual environment deps from \"setup.py\"\n\
  pip-requirements     Build virtual environment deps from \"requirements.txt\"\n\
  py-venv-clear        Delete virtual environment \"$(MAKESTER__VENV_HOME)\"\n\
  py-venv-init         Build virtual environment \"$(MAKESTER__VENV_HOME)\"\n\
  py-venv-repl         Start the vitual environment Python REPL\n\
  py-venv-vars         Display your environment Python setup\n"

.PHONY: package
