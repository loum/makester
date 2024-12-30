ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := py-help
endif

ifndef MAKESTER__PRIMED
$(info ### Add the following include statement to your Makefile)
$(info include makester/makefiles/makester.mk)
$(error ### missing include dependency)
endif

MAKESTER__PYTHONPATH ?= $(MAKESTER__PROJECT_DIR)/src
MAKESTER__TESTS_PYTHONPATH ?= $(MAKESTER__PROJECT_DIR)/tests

# Set PYTHONPATH as per "src layout". See https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/
export PYTHONPATH := $(MAKESTER__PYTHONPATH)

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

py-deps:
	$(info ### Displaying "$(MAKESTER__PACKAGE_NAME)" package dependencies ...)
	@pipdeptree

# Private Makefile includes that leverage capabilities in this Makefile.
#
include $(MAKESTER__MAKEFILES)/_py-venv.mk
include $(MAKESTER__MAKEFILES)/_py-proj.mk

py-distribution:
	$(MAKESTER__PYTHON) -m build

py-fmt-src:
	$(info ### Formatting Python files under "$(MAKESTER__PYTHONPATH)")
	@black $(MAKESTER__PYTHONPATH)

py-fmt-tests:
	$(info ### Formatting Python files under "$(MAKESTER__TESTS_PYTHONPATH)")
	@black $(MAKESTER__TESTS_PYTHONPATH)

py-fmt-all: py-fmt-src py-fmt-tests

py-fmt:
	$(call check-defined, FMT_PATH)
	$(info ### Formatting Python files under "$(FMT_PATH)")
	@black $(FMT_PATH)

py-lint-src:
	$(info ### Linting Python files under "$(MAKESTER__PYTHONPATH)")
	@ruff check $(MAKESTER__PYTHONPATH)

py-lint-tests:
	$(info ### Linting Python files under "$(MAKESTER__TESTS_PYTHONPATH)")
	@ruff check $(MAKESTER__TESTS_PYTHONPATH)

py-lint-all: py-lint-src py-lint-tests

py-lint:
	$(call check-defined, LINT_PATH)
	$(info ### Linting Python files under "$(LINT_PATH)")
	@ruff check $(LINT_PATH)

MAKESTER__MYPY_OPTIONS ?= --disallow-untyped-defs
py-type-src:
	$(info ### Type annotating Python files under "$(MAKESTER__PYTHONPATH)")
	@mypy $(MAKESTER__MYPY_OPTIONS) $(MAKESTER__PYTHONPATH)

py-type-tests:
	$(info ### Type annotating Python files under "$(MAKESTER__TESTS_PYTHONPATH)")
	@mypy $(MAKESTER__MYPY_OPTIONS) $(MAKESTER__TESTS_PYTHONPATH)

py-type-all: py-type-src py-type-tests

py-type:
	$(call check-defined, TYPE_PATH)
	$(info ### Type annotating Python files under "$(TYPE_PATH)")
	@mypy $(MAKESTER__MYPY_OPTIONS) $(TYPE_PATH)

define py-vars-header
	printf "\n%60s\n" " " | tr ' ' '-'
	printf "Makester Python variables\n"
	printf "%60s\n" " " | tr ' ' '-'
endef

py-vars: _py-vars py-venv-vars
_py-vars:
	$(call py-vars-header)
	$(call help-line,System python3:,$(MAKESTER__SYSTEM_PYTHON3))
	$(call help-line,System python3 version:,$(MAKESTER__PY3_VERSION))

py-check: py-fmt-all py-lint-all py-type-all

py-help: _py-help _py-venv-help _py-proj-help

_py-help:
	printf "\n($(MAKESTER__MAKEFILES)/py.mk)\n"
	$(call help-line,py-check,All-in-one code validator)
	$(call help-line,py-dep,Display Python package dependencies for \"$(MAKESTER__PACKAGE_NAME)\")
	$(call help-line,py-distribution,Create a versioned archive file that contains your Python project's packages)
	$(call help-line,py-fmt,Format Python modules defined by \"FMT_PATH\")
	$(call help-line,py-fmt-all,Format all Python modules under \"$(MAKESTER__PYTHONPATH)\")
	$(call help-line,py-install,Install Python project package dependencies)
	$(call help-line,py-lint,Lint Python modules defined by \"LINT_PATH\")
	$(call help-line,py-lint-all,Lint all Python modules under \"$(MAKESTER__PYTHONPATH)\")
	$(call help-line,py-vars,Display system Python settings)
