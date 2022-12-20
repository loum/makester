# Python

Handy Python tooling.

!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4)"
    Renamed from `makefiles/python-venv.mk`

## Command Reference
### Create a Simple Python Project Directory Layout
!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4)"

Quick start Python project based on [Packaging Python Projects](https://packaging.python.org/en/latest/tutorials/packaging-projects/).
```
make py-project-create
```

!!! note
    Defaults to [src-layout](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/).

For example, given `MAKESTER__PROJECT_DIR=/var/tmp/fruit`:
```
MAKESTER__PACKAGE_NAME=banana make py-project-create
```

Makester will produce the following directory layout:
```
/var/tmp/fruit
├── LICENSE.md
├── pyproject.toml
├── src
│   └── banana
│       └── __init__.py
└── tests
    └── banana
```

### Create a Python Distribution Package
!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4)"

Create a versioned archive file that contains your Python packages:
```
make py-distribution
```
See [# Packaging Python Projects](https://packaging.python.org/en/latest/tutorials/packaging-projects/) for more information.

### Display your Local Environment's Python Setup
!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4)"

```
make py-vars
```

```
### System python3: <$HOME>/.pyenv/shims/python3
### System python3 version: Python 3.10.8
### ---
### Virtual env tooling: <$HOME>/.pyenv/shims/python3 -m venv
### Virtual env Python: <$HOME>/dev/makester/venv/bin/python
### Virtual env pip: <$HOME>/dev/makester/venv/bin/pip
```

### Build Virtual Environment `venv`
!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4)"

```
make py-venv-create
```

!!! note
    Makester virtual environment creation will also automatically update `pip`
    and `setuptools` versions to the latest whilst also installing the `wheel` package.

### Delete Virtual Environment `venv`
!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4)"

```
make py-venv-clear
```

### Install Python Package Dependencies from `requirements.txt`
`pip` editable install with package dependencies taken from `requirements.txt`:
```
make pip-requirements
```

### Install Python Package Dependencies from `setup.py`
`pip` editable install with package dependencies taken from `setup.py`:
```
make pip-editable
```

### Install Python Package Dependencies from `pyproject.toml`
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

### Build Python Package from `setup.py`
Write wheel package to `--wheel-dir` (defaults to `~/wheelhouse`):
```
make package
```

### Invoke the Python Virtual Environment REPL
```
make py
```

### Show Python Package Dependencies
Leverage the awesome [pipdeptree](https://pypi.org/project/pipdeptree/) tool.
```
make py-deps
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

###`MAKESTER__PYTHON_PROJECT_ROOT`
Path to the Python package contents. For example, `MAKESTER__PYTHON_PROJECT_ROOT` would
be `<MAKESTER__PROJECT_DIR>/project/src/my_package` if your Python project structure follows this format:
```
project/
└── src/
    └── my_package/
        ├── __init__.py
        └── example.py
```
