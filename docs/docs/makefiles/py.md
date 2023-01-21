# Python

Handy Python tooling.

!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4)"
    Renamed from `makefiles/python-venv.mk`

## Command reference
### Create a Simple Python Project Directory Layout
!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4)"

Quick start Python project based on [Packaging Python Projects](https://packaging.python.org/en/latest/tutorials/packaging-projects/).
``` sh
make py-project-create
```

!!! note
    Defaults to [src-layout](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/).

For example, given `MAKESTER__PROJECT_DIR=/var/tmp/fruit`:
``` sh
MAKESTER__PACKAGE_NAME=banana make py-project-create
```

Makester will produce the following directory layout:
``` sh
/var/tmp/fruit
├── LICENSE.md
├── pyproject.toml
├── src
│   └── banana
│       └── __init__.py
└── tests
    └── banana
```

### Create a Python distribution package
!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4)"

Create a versioned archive file that contains your Python packages:
``` sh
make py-distribution
```
See [Packaging Python Projects](https://packaging.python.org/en/latest/tutorials/packaging-projects/) for more information.

### Display your local environment's Python setup
!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4)"

``` sh
make py-vars
```

``` sh
### System python3: <$HOME>/.pyenv/shims/python3
### System python3 version: Python 3.10.8
### ---
### Virtual env tooling: <$HOME>/.pyenv/shims/python3 -m venv
### Virtual env Python: <$HOME>/dev/makester/venv/bin/python
### Virtual env pip: <$HOME>/dev/makester/venv/bin/pip
```

### Build virtual environment `venv`
!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4)"

``` sh
make py-venv-create
```

!!! note
    Makester virtual environment creation will also automatically update `pip`
    and `setuptools` versions to the latest whilst also installing the `wheel` package.

### Delete virtual environment `venv`
!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4)"

``` sh
make py-venv-clear
```

### Install Python package dependencies from `requirements.txt`

`pip` editable install with package dependencies taken from `requirements.txt`:

``` sh
make pip-requirements
```

### Install Python package dependencies from `setup.py`

`pip` editable install with package dependencies taken from `setup.py`:

```
make pip-editable
```

### Install Python package dependencies from `pyproject.toml`

!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4)"

As per [PEP 660](https://peps.python.org/pep-0660/), editable installs are now supported from `pyproject.toml`:
```
make py-install
```

!!! note
    `pip` editable installs via `pyproject.toml` are supported in conjuction
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

!!! tag "[Makester v0.2.1](https://github.com/loum/makester/releases/tag/0.2.1)"

Use the [black](https://pypi.org/project/black/) code formatter across all of your Python modules
under `$MAKESTER__PROJECT_DIR/src`.

``` sh
make py-fmt-all
```

``` sh title="Sample formatter output."
### Formatting Python files under "<$MAKESTER__PROJECT_DIR>/src"
All done! ✨ 🍰 ✨
4 files left unchanged.
```

Change the `SRC` path to `black` by overriding `MAKESTER__PYTHONPATH`:

``` sh
MAKESTER__PYTHONPATH=tests make py-fmt-all
```

To target a subset of your project, or even individual files with the `py-fmt`
target:

``` sh
make py-fmt
```

Without providing a `FMT_PATH`, the command will error:

``` sh title="Formatting error without setting a path."
### "FMT_PATH" undefined
###
makefiles/py.mk:79: *** ###.  Stop.
```

The following example demonstrates how to set `FMT_PATH` for a single Python module:
``` sh title="Formatting a Python module."
FMT_PATH=src/makester/templater.py make py-fmt
```

``` sh title="Sample formatter output when setting FMT_PATH."
### Formatting Python files under "src/makester/templater.py"
All done! ✨ 🍰 ✨
1 file left unchanged.
```

Directory paths to Python modules are also supported:
``` sh title="Formatting Python modules under a given path."
FMT_PATH=src/makester make py-fmt
```

``` sh title="Sample formatter output when setting FMT_PATH with a path to Python modules."
### Formatting Python files under "src/makester"
All done! ✨ 🍰 ✨
4 files left unchanged.
```

### Lint your Python modules

!!! tag "[Makester v0.2.1](https://github.com/loum/makester/releases/tag/0.2.1)"

Use the [pylint](https://pypi.org/project/pylint/) code linter across all of your Python modules
under `$MAKESTER__PROJECT_DIR/src`.

``` sh
make py-lint-all
```

``` sh title="Sample linter output."
### Linting Python files under "<$MAKESTER__PROJECT_DIR>/src"

--------------------------------------------------------------------
Your code has been rated at 10.00/10 (previous run: 10.00/10, +0.00)
```

Change the path to `pylint` by overriding `MAKESTER__PYTHONPATH`:

``` sh
MAKESTER__PYTHONPATH=src/makester make py-lint-all
```

To target a subset of your project, or even individual files with the `py-lint`
target:

``` sh
make py-fmt
```

Without providing a `LINT_PATH`, the command will error:

``` sh title="Linting error without setting a path."
### "LINT_PATH" undefined
###
makefiles/py.mk:88: *** ###.  Stop.
```

The following example demonstrates how to set `LINT_PATH` for a single Python module:

``` sh title="Linting a Python module."
LINT_PATH=src/makester/templater.py make py-lint
```

``` sh title="Sample linter output when setting LINT_PATH."
### Linting Python files under "src/makester/templater.py"

--------------------------------------------------------------------
Your code has been rated at 10.00/10 (previous run: 10.00/10, +0.00)
```

Directory paths to Python modules are also supported:

``` sh title="Linting Python modules under a given path."
LINT_PATH=src/makester make py-lint
```

``` sh title="Sample linter output when setting LINT_PATH with a path to Python modules."
### Linting Python files under "src/makester"

--------------------------------------------------------------------
Your code has been rated at 10.00/10 (previous run: 10.00/10, +0.00)
```

## Variables
### `MAKESTER__SYSTEM_PYTHON`
Path to the current system-wide `python` executable. In Makester context, this
should only be used to create a Python virtual environment for your project.

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
