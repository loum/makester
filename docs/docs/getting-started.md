# Getting started

## Installing Makester in standalone mode

Makester is installed by running one of the following commands in your terminal. You can install
this via the command-line with either `curl`, `wget` or another similar tool.

| Method   | Command                                                                                        |
| -------- | ---------------------------------------------------------------------------------------------- |
| curl     | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/loum/makester/main/tools/install.sh)"`  |
| wget     | `sh -c "$(wget -O- https://raw.githubusercontent.com/loum/makester/main/tools/install.sh)"`    |
| fetch	   | `sh -c "$(fetch -o - https://raw.githubusercontent.com/loum/makester/main/tools/install.sh)"`  |

## Integrating Makester into a new project

Begin by assigning your new project name to the `MAKESTER__PRIMER_PROJECT_NAME`. This will eventually
be assigned to the [MAKESTER\_\_PROJECT_NAME](makefiles/makester.md#makester__project_name)
Makester variable. The following example uses the primer project name `supa-idea`:

```sh
export MAKESTER__PRIMER_PROJECT_NAME=supa-idea
```

Prime your new project repository:

```sh
mkdir $MAKESTER__PRIMER_PROJECT_NAME && cd $_ && git init && git commit -m "initial commit" --allow-empty
```

Next, prepare your `Makefile`. The `Makefile` will feature targets that can help you get things done.
Select a scenario from below.

### Brand new generic project

For a generic project, or if you want the most minimal `Makefile` simply to get you started:

```sh
make -f ~/.makester/Makefile makester-minimal
```

Should should be able to access your project's help:

```sh
make help
```

You can now evolve your `Makefile` to suit your project needs.

### Brand new Python project

Makester tooling can provide opionionated scaffolding for common components of a Python coding project.

```sh title="Initialise Python project boilerplate."
make -f ~/.makester/Makefile py-proj-makefile && make py-proj-primer
```

#### What just happened?

Makester takes care of the of the Python project scaffolding for you. You now have the basic boilerplate for a
new Python coding project and can start work immediately on your problem domain. This includes:

- [src-layout](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/){target="\_blank"}
  based on [Packaging Python Projects](https://packaging.python.org/en/latest/tutorials/packaging-projects/){target="\_blank"}.
- A sane, `.gitignore`, [MIT license](https://en.wikipedia.org/wiki/MIT_License){target="\_blank"}
  coverage and a basic `README.md`.
- Documentation scaffolding. [More details on how to evolve the documentation suite](makefiles/docs.md#site-documentation-scaffolding).
- Pylint configuration. [More targeted configuration options for linting](makefiles/py.md#create-a-pylint-configuration).
- [mypy](https://mypy-lang.org/) for code type annotation and [black](https://pypi.org/project/black/)
  for code formatting are ready to go. See [make py-check](makefiles/py.md#all-in-one-code-checker).
- Placeholder for a project CLI that defaults to the `MAKESTER__PROJECT_NAME`. This can be invoked
  with `venv/bin/<MAKESTER__PROJECT_NAME>`
- [Dynamic versioning](makefiles/versioning.md#generate-dynamic-version).

## Existing project

If you already have a `Makefile`, then just include Makester:

```sh
#
# Makester overrides.
#
MAKESTER__STANDALONE := true

include $(HOME)/.makester/makefiles/makester.mk
```

## Maintenance

Keep up-to-date with Makester:

```sh
sh $HOME/.makester/tools/install.sh --upgrade
```

______________________________________________________________________

[top](#getting-started)
