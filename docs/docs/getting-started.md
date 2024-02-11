# Getting started

## Brand new (Python) project

Makester tooling can provide scaffolding for common components of a coding project. Begin by assigning
your new project name to the [MAKESTER__PROJECT_NAME](../makefiles/makester/#makester__project_name)
environment variable. The following example uses the project name `supa-idea`:

``` sh
export MAKESTER__PROJECT_NAME=supa-idea
```

Prime your new project repository:

``` sh
mkdir $MAKESTER__PROJECT_NAME && cd $_ && git init && git commit -m "initial commit" --allow-empty
```

Add `Makester` as a submodule in your `git` project repository:

``` sh
git submodule add https://github.com/loum/makester.git
```

!!! note
    Some versions of `git submodule add` will only `fetch` the submodule folder without any content.
    For first time initialisation (`pull` the submodule):
    
    ``` sh
    git submodule update --init --recursive
    ```

The `-i` switch will also install the Makester tooling that will be used in the following steps.

### Create the Python project directory layout
Let Makester prepare your Python project boilerplate, by initialising with the `-a` switch:

``` sh title="Initialise Python project boilerplate."
makester/resources/scripts/primer.sh -a
```

### What just happened?
Makester takes care of the of the Python project scaffolding for you. You now have the basic boilerplate for a
new Python coding project and can start work immediately on your problem domain. This includes:

- [src-layout](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/){target="_blank"}
based on [Packaging Python Projects](https://packaging.python.org/en/latest/tutorials/packaging-projects/){target="_blank"}.
- A sane, `.gitignore`, [MIT license](https://en.wikipedia.org/wiki/MIT_License){target="_blank"}
coverage and a basic `README.md`.
- Documentation scaffolding. [More details on how to evolve the documentation suite](../makefiles/docs/#site-documentation-scaffolding).
- Pylint configuration. [More targetted configuration options for linting](../makefiles/docs/#create-a-pylint-configuration).
- [mypy](https://mypy-lang.org/) for code type annotation and [black](https://pypi.org/project/black/)
for code formatting are ready to go. See [make py-check](../makefiles/docs/#all-in-one-code-checker).
- Placeholder for a project CLI that defaults to the `MAKESTER__PROJECT_NAME`. This can be invoked
  with `venv/bin/<MAKESTER__PROJECT_NAME>`
- Makester tooling that is ephemeral and does not polute your project code base.

## Existing project

If you already have a `Makefile`, then just include Makester:

```
include makester/makefiles/makester.mk
```

Run the primer script to build a minimal `Makefile`:

``` sh
makester/resources/scripts/primer.sh -i
```

## Maintenance
!!! tag "[Makester v0.2.6](https://github.com/loum/makester/releases/tag/0.2.6)"

To get the latest `Makester` release:

```
resources/scripts/primer.sh -u
```

!!! note
    Prior to [Makester v0.2.6](https://github.com/loum/makester/releases/tag/0.2.6) you will first need
    to sync the Makester `git` submodule:
    ``` sh
    make submodule-update
    ```

## Minimal mode
!!! tag "[Makester v0.2.3](https://github.com/loum/makester/releases/tag/0.2.3)"

In certain circumstances, you may only need a limited subset of Makester capability. It is
possible to include only the Makester `Makefile`s that you need with the `MAKESTER__INCLUDES`
environment variable. For example, to limit Makester to Python tooling, set `MAKESTER__INCLUDES`
as follows:

``` sh title="Makester minimal mode."
MAKESTER__INCLUDES=py
```

To make the settings persist, add the expression to your project's Makefile before the
`include makefiles/makester.mk` call:

``` sh title="Project Makefile in minimal mode."
.SILENT:
.DEFAULT_GOAL := help

MAKESTER__INCLUDES := py

include makefiles/makester.mk

help: makester-help
    @echo "(Makefile)\n"
```

---
[top](#getting-started)
