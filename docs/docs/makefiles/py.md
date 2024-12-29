# Python

Handy Python tooling.

!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4){target="\_blank"}"

## Getting started

Ensure a Python 3 interpreter is available in your path
[(we recommend installing pyenv)](https://github.com/pyenv/pyenv){target="\_blank"}.

The Makester Python subsystem aims to be a light-weight, pure-Python implementation of your
project's Python project environment management with basic tooling. Unlike
[Conda](https://docs.conda.io/en/latest/){target="\_blank"} and [Poetry](https://python-poetry.org/){target="\_blank"},
or the like, no additional software installs or new learnings are required. But again, that is not
the real problem Makester is trying to solve and does not care if you insist on using a third-party tool for your
Python packaging and dependency management. Simply abstract those commands behind a `make` target.
This allows you to swap out and/or implement a hybrid Python packaging and dependency management
system, if that is what you really want to do.

## Command reference

### Create a simple Python project directory layout

!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4){target="\_blank"}"
    Quick start Python project based on [Packaging Python Projects](https://packaging.python.org/en/latest/tutorials/packaging-projects/){target="\_blank"}.

```sh
make py-proj-create
```

!!! note
    Defaults to [src-layout](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/){target="\_blank"}.

For example, given `MAKESTER__PROJECT_DIR=/var/tmp/fruit`:

```sh
MAKESTER__PACKAGE_NAME=banana make py-proj-create
```

Makester will produce the following directory layout:

```sh
/var/tmp/fruit
├── LICENSE.md
├── pyproject.toml
├── src
│   └── banana
│       └── __init__.py
└── tests
    └── banana
```

### Create a Pylint configuration

[As per Pylint configuration](https://pylint.pycqa.org/en/latest/user_guide/configuration/index.html){target="\_blank"}

```sh
make py-pylintrc
```

### Create a Python distribution package

!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4){target="\_blank"}"

Create a versioned archive file that contains your Python packages:

```sh
make py-distribution
```

See [Packaging Python Projects](https://packaging.python.org/en/latest/tutorials/packaging-projects/) for more information.

### Display your local environment's Python setup

!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4){target="\_blank"}"

```sh
make py-vars
```

```sh
### System python3: <$HOME>/.pyenv/shims/python3
### System python3 version: Python 3.10.8
### ---
### Virtual env tooling: <$HOME>/.pyenv/shims/python3 -m venv
### Virtual env Python: <$HOME>/dev/makester/venv/bin/python
### Virtual env pip: <$HOME>/dev/makester/venv/bin/pip
```

### Build virtual environment `venv`

!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4){target="\_blank"}"

```sh
make py-venv-create
```

!!! note
    Makester virtual environment creation will also automatically update `pip` and `setuptools` versions to the latest whilst also installing the `wheel` package.

### Delete virtual environment `venv`

!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4){target="\_blank"}"

```sh
make py-venv-clear
```

### Install Python package dependencies from `requirements.txt`

`pip` editable install with package dependencies taken from `requirements.txt`:

```sh
make pip-requirements
```

### Install Python package dependencies from `setup.py`

`pip` editable install with package dependencies taken from `setup.py`:

```
make pip-editable
```

### Install Python package dependencies from `pyproject.toml`

!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4){target="\_blank"}"

As per [PEP 660](https://peps.python.org/pep-0660/), editable installs are now supported from `pyproject.toml`:

```
make py-install
```

!!! note
    `pip` editable installs via `pyproject.toml` are supported together
    with [setuptools v64.0.0](https://github.com/pypa/setuptools/blob/main/CHANGES.rst#v6400)
    as the backend and [pip v21.3](https://pip.pypa.io/en/stable/news/#v21-3) as the frontend.
    Both `setuptools` and `pip` are automatically updated as part of `make py-venv-create`.

### Build Python package from `setup.py`

Write wheel package to `--wheel-dir` (defaults to `~/wheelhouse`):

```
make package
```

### Invoke the Python virtual environment REPL

```
make py
```

### Show Python package dependencies

Leverage the awesome [pipdeptree](https://pypi.org/project/pipdeptree/) tool.

```
make py-deps
```

### Format your Python modules

!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.2.1){target="\_blank"}"

Use [black](https://pypi.org/project/black/) for code formatting.

```sh
make py-fmt-all
```

```sh title="Sample formatter output."
### Formatting Python files under "<$MAKESTER__PROJECT_DIR>/src"
All done! ✨ 🍰 ✨
4 files left unchanged.
```

To target Python modules under `MAKESTER__PYTHONPATH`:

```sh
make py-fmt-src
```

Similarly for test modules, to target Python modules under `MAKESTER__TESTS_PYTHONPATH`:

```sh
make py-fmt-tests
```

To target a subset of your project, or even individual files with the `py-fmt`
target:

```sh
make py-fmt
```

Without providing a `FMT_PATH`, the command will error:

```sh title="Formatting error without setting a path."
### "FMT_PATH" undefined
###
makefiles/py.mk:79: *** ###.  Stop.
```

The following example demonstrates how to set `FMT_PATH` for a single Python module:

```sh title="Formatting a Python module."
FMT_PATH=src/makester/templater.py make py-fmt
```

```sh title="Sample formatter output when setting FMT_PATH."
### Formatting Python files under "src/makester/templater.py"
All done! ✨ 🍰 ✨
1 file left unchanged.
```

Directory paths to Python modules are also supported:

```sh title="Formatting Python modules under a given path."
FMT_PATH=src/makester make py-fmt
```

```sh title="Sample formatter output when setting FMT_PATH with a path to Python modules."
### Formatting Python files under "src/makester"
All done! ✨ 🍰 ✨
4 files left unchanged.
```

### Lint your Python modules

!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.2.1){target="\_blank"}"

Use [pylint](https://pypi.org/project/pylint/) for code linting.

```sh
make py-lint-all
```

```sh title="Sample linter output."
### Linting Python files under "<$MAKESTER__PROJECT_DIR>/src"

--------------------------------------------------------------------
Your code has been rated at 10.00/10 (previous run: 10.00/10, +0.00)
```

To target Python modules under `MAKESTER__PYTHONPATH`:

```sh
make py-lint-src
```

Similarly for test modules, to target Python modules under MAKESTER\_\_TESTS_PYTHONPATH:

```sh
make py-lint-tests
```

To target a subset of your project, or even individual files with the `py-lint`
target:

```sh
make py-lint
```

Without providing a `LINT_PATH`, the command will error:

```sh title="Linting error without setting a path."
### "LINT_PATH" undefined
###
makefiles/py.mk:88: *** ###.  Stop.
```

The following example demonstrates how to set `LINT_PATH` for a single Python module:

```sh title="Linting a Python module."
LINT_PATH=src/makester/templater.py make py-lint
```

```sh title="Sample linter output when setting LINT_PATH."
### Linting Python files under "src/makester/templater.py"

--------------------------------------------------------------------
Your code has been rated at 10.00/10 (previous run: 10.00/10, +0.00)
```

Directory paths to Python modules are also supported:

```sh title="Linting Python modules under a given path."
LINT_PATH=src/makester make py-lint
```

```sh title="Sample linter output when setting LINT_PATH with a path to Python modules."
### Linting Python files under "src/makester"

--------------------------------------------------------------------
Your code has been rated at 10.00/10 (previous run: 10.00/10, +0.00)
```

### Type annotating your Python modules

!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.2.3){target="\_blank"}"

Use [mypy](https://mypy-lang.org/) for code type annotation.

!!! note
    Makester defaults to a more strict interpretation of type annotation checks with the `--disallow-untyped-defs` switch. This can be overridden with `MAKESTER__MYPY_OPTIONS`.

```sh
make py-type-all
```

```sh title="Sample type annotation output."
### Type annotating Python files under "/Users/lomarkovski/dev/makester/src"
Success: no issues found in 4 source files
```

To target Python modules under `MAKESTER__PYTHONPATH`:

```sh
make py-type-src
```

Similarly for test modules, to target Python modules under `MAKESTER__TESTS_PYTHONPATH`:

```sh
make py-type-tests
```

To target a subset of your project, or even individual files with the `py-type` target:

```sh
make py-type
```

Without providing a `TYPE_PATH`, the command will error:

```sh title="Formatting error without setting a path."
### "TYPE_PATH" undefined
###
makefiles/py.mk:117: *** ###.  Stop.
```

The following example demonstrates how to set `TYPE_PATH` for a single Python module:

```sh title="Type annotating a Python module."
TYPE_PATH=src/makester/templater.py make py-type
```

```sh title="Sample type annotating output when setting LINT_PATH."
### Type annotating Python files under "src/makester/templater.py"
Success: no issues found in 1 source file
```

Directory paths to Python modules are also supported:

```sh title="Type annotating Python modules under a given path."
TYPE_PATH=src/makester make py-type
```

```sh title="Sample type annotation output when setting LINT_PATH with a path to Python modules."
### Type annotating Python files under "src/makester"
Success: no issues found in 4 source files
```

### Markdown formatter

!!! tag "[Makester v0.3.0](https://github.com/loum/makester/releases/tag/0.3.0){target="\_blank"}"

Use [mdformat](https://mdformat.readthedocs.io/en/stable/) as a CommonMark compliant Markdown formatter.

```sh
make py-md-fmt
```

Without providing a `MD_FMT_PATH`, the command will error:

```sh title="Markdown formatting error without setting a path."
### "MD_FMT_PATH" undefined
###
makefiles/py.mk:218: *** ###.  Stop.
```

The following example demonstrates how to set `MD_FMT_PATH` for a single Markdown file:

```sh title="Formatting a single Markdown file."
make py-md-fmt MD_FMT_PATH=docs/docs/index.md
```

```sh title="Sample formatter output when setting MD_FMT_PATH."
### Formatting Markdown files under "docs/docs/index.md"
```

Directory paths to Markdown files are also supported:

```sh title="Markdown formatting under a given path."
make py-md-fmt MD_FMT_PATH=docs
```

### All-in-one code checker

Special convenience target that runs all code check commands together.

```sh title="Lint, format and annotate in one step"
make py-check
```

## Variables

### `MAKESTER__SYSTEM_PYTHON3`

Path to the current system-wide `python` executable. In Makester context, this
should only be used to create a Python virtual environment for your project.
Makester will attempt to identify the Python interpreter from your environment path. However,
`MAKESTER__SYSTEM_PYTHON3` can also be used to override the system-wide Python.

### `MAKESTER__PYTHON`

Path to the Python virtual environment `python` executable. You can reference
this anywhere in your `Makefile` as `$(MAKESTER__PYTHON)`.

### `MAKESTER__PIP`

Path to the Python virtual environment `pip` executable. You can reference
this anywhere in your `Makefile` as `$(MAKESTER__PIP)`.

### `MAKESTER__WHEELHOUSE`

Control the location to where Python will build its wheels to.
See [wheel-dir](https://pip.pypa.io/en/stable/cli/pip_wheel/).

### `MAKESTER__PYTHON_PROJECT_ROOT`

Path to the Python package contents. For example, `MAKESTER__PYTHON_PROJECT_ROOT` would
be `<MAKESTER__PROJECT_DIR>/project/src/my_package` if your Python project structure follows this format:

```
project/
└── src/
    └── my_package/
        ├── __init__.py
        └── example.py
```

### `MAKESTER__PYTHONPATH`

Makester Python project directory structure follows the `src` layout. However, this can be
overridden with `MAKESTER__PYTHONPATH` (default to `$MAKESTER__PROJECT_DIR/src`)

`MAKESTER__PYTHONPATH` also acts as the default value for `PYTHONPATH` in your environment.

### `MAKESTER__TESTS_PYTHONPATH`

Python project `src` layout's `tests` directory location compliment (default to `$MAKESTER__PROJECT_DIR/tests`).

### `MAKESTER__MYPY_OPTIONS`

Control the switch settings to `mypy` when running type annotation across the code base (default
`--disallow-untyped-defs`).

______________________________________________________________________

[top](#python)
