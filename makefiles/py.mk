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

py-install-makester: MAKESTER__PIP_INSTALL := -e makester
py-install-makester: MAKESTER__WORK_DIR := $(PWD)/makester/.makester
py-install-makester: MAKESTER__VERSION_FILE := makester/$(MAKESTER__PYTHONPATH)/makester/VERSION
py-install-makester: MAKESTER__PROJECT_NAME := makester
py-install-makester: MAKESTER__GIT_DIR := $(PWD)/.git/modules/makester
py-install-makester: MAKESTER__GITVERSION_CONFIG := $(PWD)/makester/resources/sample/GitVersion.yml
py-install-makester: py-install

py-project-create: py-pylintrc py-setup-cfg
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

define _setup_cfg_heredoc
cat <<EOF > $1
[metadata]
name = $2
version = file: src/$2/VERSION
description = <CHANGE_ME>
long_description = file: README.md
long_description_content_type = text/markdown; charset=UTF-8
url = <CHANGE_ME>
author = <CHANGE_ME>
license = MIT
license_files = LICENSE.md
classifier =
    Development Status :: 5 - Production/Stable
    Environment :: Console
    Environment :: MacOS X
    Intended Audience :: Developers
    Topic :: Software Development :: Build Tools
    License :: OSI Approved :: MIT License
    Natural Language :: English
    Operating System :: POSIX :: Linux
    Operating System :: MacOS :: MacOS X
    Programming Language :: Python :: 3

[options]
python_requires = >=3
packages = find:
package_dir =
    =src
install_requires =

[options.extras_require]
dev =
    mkdocstrings-python
    pytest
    pytest-cov
    pytest-sugar
    twine

[options.packages.find]
where = src

[options.package_data]
$2 =
    VERSION

[options.entry_points]
console_scripts =
    $2 = $2.__main__:main
EOF
endef

export _setup_cfg_script = $(call _setup_cfg_heredoc,$(MAKESTER__SETUP_CFG),$(MAKESTER__PACKAGE_NAME))

MAKESTER__SETUP_CFG ?= $(MAKESTER__PROJECT_DIR)/setup.cfg

py-setup-cfg:
	$(info ### Writing setup.cfg to "$(MAKESTER__SETUP_CFG)" ...)
	@eval "$$_setup_cfg_script"

py-setup-cfg-rm:
	$(info ### Deleting setup.cfg to "$(MAKESTER__SETUP_CFG)" ...)
	$(shell which rm) $(MAKESTER__SETUP_CFG)

define _setup_cli_init_heredoc
cat <<EOF > $1/__init__.py
"""$2.

"""
__app_name__ = "$2"
EOF
endef

export _setup_cli_init_script = $(call _setup_cli_init_heredoc,$(MAKESTER__PYTHON_PROJECT_ROOT),$(MAKESTER__PACKAGE_NAME))

_py-cli-init:
	$(info ### Writing CLI __init__.py scaffolding under "$(MAKESTER__PYTHON_PROJECT_ROOT)" ...)
	@eval "$$_setup_cli_init_script"

_py-cli-init-rm:
	$(info ### Deleting CLI __init__.py scaffolding under "$(MAKESTER__PYTHON_PROJECT_ROOT)" ...)
	$(shell which rm) $(MAKESTER__PYTHON_PROJECT_ROOT)/__init__.py

define _setup_cli_main_heredoc
cat <<EOF > $1/__main__.py
"""$2 CLI.

"""
import typer


app = typer.Typer(
    add_completion=False,
    help="makefiles CLI tool",
)


@app.command()


def main() -> None:
    """Script entry point."""
    app()


if __name__ == "__main__":
    main()
EOF
endef

export _setup_cli_main_script = $(call _setup_cli_main_heredoc,$(MAKESTER__PYTHON_PROJECT_ROOT),$(MAKESTER__PACKAGE_NAME))

_py-cli-main:
	$(info ### Writing CLI __main__.py scaffolding under "$(MAKESTER__PYTHON_PROJECT_ROOT)" ...)
	@eval "$$_setup_cli_main_script"

_py-cli-main-rm:
	$(info ### Deleting CLI __main__.py scaffolding under "$(MAKESTER__PYTHON_PROJECT_ROOT)" ...)
	$(shell which rm) $(MAKESTER__PYTHON_PROJECT_ROOT)/__main__.py

py-cli:
	$(shell which mkdir) -pv $(MAKESTER__PYTHON_PROJECT_ROOT)
	$(MAKE) _py-cli-init _py-cli-main

py-cli-rm:
	$(MAKE) _py-cli-init-rm _py-cli-main-rm

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

py-md-fmt:
	$(call check-defined, MD_FMT_PATH)
	$(info ### Formatting Markdown files under "$(MD_FMT_PATH)")
	@mdformat $(MD_FMT_PATH)

py-lint-src:
	$(info ### Linting Python files under "$(MAKESTER__PYTHONPATH)")
	@pylint $(MAKESTER__PYTHONPATH)

py-lint-tests:
	$(info ### Linting Python files under "$(MAKESTER__TESTS_PYTHONPATH)")
	@pylint $(MAKESTER__TESTS_PYTHONPATH)

py-lint-all: py-lint-src py-lint-tests

py-lint:
	$(call check-defined, LINT_PATH)
	$(info ### Linting Python files under "$(LINT_PATH)")
	@pylint $(LINT_PATH)

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

py-vars: _py-vars py-venv-vars
_py-vars:
	$(info ### System python3: $(MAKESTER__SYSTEM_PYTHON3))
	$(info ### System python3 version: $(MAKESTER__PY3_VERSION))

py-check: py-fmt-all py-lint-all py-type-all

py-help: _py-help _py-venv-help

_py-help:
	@echo "($(MAKESTER__MAKEFILES)/py.mk)\n\
  py-check             All-in-one code validator\n\
  py-cli               Add new CLI scaffolding for \"$(MAKESTER__PACKAGE_NAME)\"\n\
  py-dep               Display Python package dependencies for \"$(MAKESTER__PACKAGE_NAME)\"\n\
  py-distribution      Create a versioned archive file that contains your Python project's packages\n\
  py-fmt               Format Python modules defined by \"FMT_PATH\"\n\
  py-fmt-all           Format all Python modules under \"$(MAKESTER__PYTHONPATH)\"\n\
  py-install           Install Python project package dependencies\n\
  py-lint              Lint Python modules defined by \"LINT_PATH\"\n\
  py-lint-all          Lint all Python modules under \"$(MAKESTER__PYTHONPATH)\"\n\
  py-md-fmt            Format Markdown files defined by \"MD_FMT_PATH\"\n\
  py-project-create    Create a minimal Python project directory structure scaffolding\n\
  py-pylintrc          Add new pylint configuration to \"$(MAKESTER__PYLINT_RCFILE)\"\n\
  py-setup-cfg         Add new setup.cfg configuration to \"$(MAKESTER__SETUP_CFG)\"\n\
  py-vars              Display system Python settings\n"
