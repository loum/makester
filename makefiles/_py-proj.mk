ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := _py-proj-help
endif

# Heredoc for the pyproject.toml
#
define _pyproject_toml_heredoc
cat <<EOF > $1
[build-system]
requires = [
    "setuptools",
    "wheel",
    "setuptools-git-versioning>=2.0,<3",
]
build-backend = "setuptools.build_meta"

[project]
name = "$2"
authors = [
    {name = "<CHANGE_ME>", email = "CHANGE_ME@email.com"},
]
description = "<CHANGE_ME>"
readme = "README.md"
requires-python = ">=3"
license = {file = "LICENSE.md"}
classifiers = [
    "Development Status :: 5 - Production/Stable",
    "Environment :: Console",
    "Environment :: MacOS X",
    "Intended Audience :: Developers",
    "Topic :: Software Development :: Build Tools",
    "License :: OSI Approved :: MIT License",
    "Natural Language :: English",
    "Operating System :: POSIX :: Linux",
    "Operating System :: MacOS :: MacOS X",
    "Programming Language :: Python :: 3",
]
dependencies = []
dynamic = ["version"]

[tool.setuptools-git-versioning]
enabled = true
version_file = "src/$2/VERSION"

[project.optional-dependencies]
dev = [
    "mkdocstrings-python",
    "pytest",
    "pytest-cov",
    "pytest-sugar",
    "ruff",
    "structlog",
    "twine",
    "typer",
]

[tool.setuptools.packages.find]
where = ["src"]

[project.scripts]
$2 = "$2.__main__:app"

[tool.ruff]
target-version = "py37"
line-length = 120
fix = true

[tool.ruff.lint]
select = [
    # flake8-2020
    "YTT",
    # flake8-bandit
    "S",
    # flake8-bugbear
    "B",
    # flake8-builtins
    "A",
    # flake8-comprehensions
    "C4",
    # flake8-debugger
    "T10",
    # flake8-simplify
    "SIM",
    # isort
    "I",
    # mccabe
    "C90",
    # pycodestyle
    "E", "W",
    # pyflakes
    "F",
    # pygrep-hooks
    "PGH",
    # pyupgrade
    "UP",
    # ruff
    "RUF",
    # tryceratops
    "TRY",
    # pylint
    "PLC", "PLE", "PLR", "PLW",
    # pep8-naming
    "N",
    # pydocstyle
    "D",
    # pylint
    "PLC", "PLE", "PLR", "PLW",
    # pep8-naming
    "N",
    # pydocstyle
    "D",
]
ignore = [
    # DoNotAssignLambda
    "E731",
]

[tool.ruff.format]
preview = true
EOF
endef

MAKESTER__PYPROJECT_TOML ?= $(MAKESTER__PROJECT_DIR)/pyproject.toml

export _pyproject_toml_script = $(call _pyproject_toml_heredoc,$(MAKESTER__PYPROJECT_TOML),$(MAKESTER__PACKAGE_NAME))

py-proj-toml-create:
	$(info ### Writing pyproject.toml to "$(MAKESTER__PYPROJECT_TOML)" ...)
	@eval "$$_pyproject_toml_script"

py-proj-toml-rm:
	$(info ### Deleting pyproject.toml from "$(MAKESTER__PYPROJECT_TOML)" ...)
	$(shell which rm) $(MAKESTER__PYPROJECT_TOML)

define _py_makefile_heredoc
cat <<'EOF' > Makefile
.SILENT:
.DEFAULT_GOAL := help

#
# Makester overrides.
#
MAKESTER__STANDALONE := true

include $$(HOME)/.makester/makefiles/makester.mk

MAKESTER__PROJECT_NAME := $1
MAKESTER__VERSION_FILE := src/$$(MAKESTER__PACKAGE_NAME)/VERSION

#
# Local Makefile targets.
#

# Build the local development environment.
#
init-dev: py-venv-clear py-venv-init
	MAKESTER__PIP_INSTALL_EXTRAS=dev $$(MAKE) py-install-extras

# Streamlined production packages.
#
init: _venv-init
	$$(MAKE) py-install

help: makester-help
	printf "\n(Makefile)\n"
	$$(call help-line,init,Build \"$1\" environment streamlined for production releases)
	$$(call help-line,init-dev,Build \"$1\" environment)
EOF
endef

export _py_makefile_script = $(call _py_makefile_heredoc,$(MAKESTER__PRIMER_PROJECT_NAME))

py-proj-makefile:
	$(info ### Writing Makefile to $(PWD)/Makefile...)
	@eval "$$_py_makefile_script"

# Heredoc for the CLI __init__.py
#
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
	$(shell which mkdir) -pv $(MAKESTER__PYTHON_PROJECT_ROOT)
	@eval "$$_setup_cli_init_script"

_py-cli-init-rm:
	$(info ### Deleting CLI __init__.py scaffolding under "$(MAKESTER__PYTHON_PROJECT_ROOT)" ...)
	$(shell which rm) $(MAKESTER__PYTHON_PROJECT_ROOT)/__init__.py

# Heredoc for the CLI __main__.py
#
define _setup_cli_main_heredoc
cat <<EOF > $1/__main__.py
"""$2 CLI.

"""
import typer

from .logging_config import log


app = typer.Typer(add_completion=False, help="CLI tool")


@app.command()
def supa_idea() -> None:
    """Command placeholder."""
    log.info("Looks like you invoked the supa_idea command 🤓")
EOF
endef

export _setup_cli_main_script = $(call _setup_cli_main_heredoc,$(MAKESTER__PYTHON_PROJECT_ROOT),$(MAKESTER__PACKAGE_NAME))

_py-cli-main:
	$(info ### Writing CLI __main__.py scaffolding under "$(MAKESTER__PYTHON_PROJECT_ROOT)" ...)
	$(shell which mkdir) -pv $(MAKESTER__PYTHON_PROJECT_ROOT)
	@eval "$$_setup_cli_main_script"

py-proj-cli: _py-cli-init _py-cli-main

_py-cli-main-rm:
	$(info ### Deleting CLI __main__.py scaffolding under "$(MAKESTER__PYTHON_PROJECT_ROOT)" ...)
	$(shell which rm) $(MAKESTER__PYTHON_PROJECT_ROOT)/__main__.py

py-proj-cli-rm: _py-cli-init-rm _py-cli-main-rm

# Heredoc for the logging_config.py.
#
define _logging_config_heredoc
cat <<'EOF' > $1/logging_config.py
"""Logging configuration."""

from __future__ import annotations

import logging
import logging.config
import os
from typing import TYPE_CHECKING

import structlog

if TYPE_CHECKING:
    import structlog.stdlib


def suppress_logging():
    """Provides an overriding (to level `CRITICAL`) suppression mechanism
    for all loggers which takes precedence over the logger`s own level.

    This function can be useful when the need arises to temporarily throttle logging output down
    across the whole application.

    Technically, this function will disable all logging calls below severity level
    `CRITICAL`.

    """
    logging.disable(logging.ERROR)


timestamper = structlog.processors.TimeStamper(fmt="%Y-%m-%d %H:%M:%S")
pre_chain = [
    # Add the log level and a timestamp to the event_dict if the log entry
    # is not from structlog.
    structlog.stdlib.add_log_level,
    # Add extra attributes of LogRecord objects to the event dictionary
    # so that values passed in the extra parameter of log methods pass
    # through to log output.
    structlog.stdlib.ExtraAdder(),
    timestamper,
]


def extract_from_record(
    _: structlog.stdlib._FixedFindCallerLogger, __: str, event_dict: dict
) -> dict:
    """Extract thread and process names and add them to the event dict."""
    record = event_dict["_record"]
    event_dict["thread"] = record.threadName

    return event_dict


logging.config.dictConfig(
    {
        "version": 1,
        "disable_existing_loggers": False,
        "formatters": {
            "plain": {
                "()": structlog.stdlib.ProcessorFormatter,
                "processors": [
                    structlog.stdlib.ProcessorFormatter.remove_processors_meta,
                    structlog.dev.ConsoleRenderer(colors=False),
                ],
                "foreign_pre_chain": pre_chain,
            },
            "colored": {
                "()": structlog.stdlib.ProcessorFormatter,
                "processors": [
                    extract_from_record,
                    structlog.stdlib.ProcessorFormatter.remove_processors_meta,
                    structlog.dev.ConsoleRenderer(colors=True),
                ],
                "foreign_pre_chain": pre_chain,
            },
        },
        "handlers": {
            "default": {
                "level": os.environ.get("LOG_LEVEL", "INFO").upper(),
                "class": "logging.StreamHandler",
                "formatter": "plain",
            },
        },
        "loggers": {
            "": {
                "handlers": ["default"],
                "level": os.environ.get("LOG_LEVEL", "INFO").upper(),
                "propagate": True,
            },
        },
    }
)
structlog.configure(
    processors=[
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        timestamper,
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.stdlib.ProcessorFormatter.wrap_for_formatter,
    ],
    logger_factory=structlog.stdlib.LoggerFactory(),
    wrapper_class=structlog.stdlib.BoundLogger,
    cache_logger_on_first_use=True,
)

log = structlog.get_logger("webapp")
EOF
endef

export _logging_config_script = $(call _logging_config_heredoc,$(MAKESTER__PYTHON_PROJECT_ROOT))

py-proj-logging-config:
	$(info ### Writing logging configuration under "$(MAKESTER__PYTHON_PROJECT_ROOT)" ...)
	$(shell which mkdir) -pv $(MAKESTER__PYTHON_PROJECT_ROOT)
	@eval "$$_logging_config_script"

py-proj-logging-config-rm:
	$(info ### Deleting logging configuration under "$(MAKESTER__PYTHON_PROJECT_ROOT)" ...)
	$(shell which rm) $(MAKESTER__PYTHON_PROJECT_ROOT)/logging_config.py

py-proj-create: py-proj-toml-create
	$(info ### Creating a Python project directory structure under $(MAKESTER__PYTHON_PROJECT_ROOT))
	@$(shell which mkdir) -pv $(MAKESTER__PYTHON_PROJECT_ROOT)
	@$(shell which touch) $(MAKESTER__PYTHON_PROJECT_ROOT)/__init__.py
	@$(shell which mkdir) -pv $(MAKESTER__PROJECT_DIR)/tests/$(MAKESTER__PACKAGE_NAME)
	@$(shell which cp) $(MAKESTER__RESOURCES_DIR)/blank_directory.gitignore $(MAKESTER__PROJECT_DIR)/tests/$(MAKESTER__PACKAGE_NAME)/.gitignore

py-proj-primer: makester-repo-ceremony py-proj-create py-proj-logging-config py-proj-cli docs-bootstrap gitversion-release

_py-proj-help:
	printf -- "-%.0s" {1..10}; printf "\n"
	$(call help-line,py-proj-cli,Add new CLI scaffolding for \"$(MAKESTER__PACKAGE_NAME)\")
	$(call help-line,py-proj-cli-rm,Add new CLI scaffolding for \"$(MAKESTER__PACKAGE_NAME)\")
	$(call help-line,py-proj-create,Create a minimal Python project directory structure scaffolding)
	$(call help-line,py-proj-logging-config,Create project logging configuration)
	$(call help-line,py-proj-makefile,Create a project Makefile)
	$(call help-line,py-proj-toml-create,Add new pyproject.toml configuration to \"$(MAKESTER__PYPROJECT_TOML)\")
