#####################################################
Makester - Common Project Build/Management Components
#####################################################

Centralised repository for common tasks that you use everyday in your coding projects.

Created in response to a proliferation of disjointed Makefiles over the years.  Now, projects can follow a consistent infrastructure management pattern that is version controlled and easy to use.

If you use Docker, `docker-compose` and Python virtual environments regularly then read on.

*************
Prerequisties
*************

- `Docker <https://docs.docker.com/install/>`_

***************
Getting Started
***************

Get the code and change into the top level `git` project directory::

    $ git clone https://github.com/loum/makester.git && cd makester

.. note::

    Run all commands from the top-level directory of the `git` repository.

****************
Project Overview
****************

The `Makester` project layout features a grouping of `Makefiles` under the `makefiles` directory::

  $ tree makefiles/
  makefiles/
  ├── base.mk
  ├── docker.mk
  └── python-venv.mk

Each `Makefile` is a group of concerns for a particular project build/infrastructure component.  For example, `makefiles/python-venv.mk` has targets that allow you to create and manage Python virtual environments.

To use, add `Makester` as a submodule in your `git` project repository::

  $ git submodule add https://github.com/loum/makester.git

Create a `Makefile` at the top-level of your `git` project repository.

Include the required makefile targets into your `Makefile`.  For example::

    include makester/makefiles/base.mk

.. note::

    Remember to regularly get the latest `Makester` code base::

        $ git submodule update --remote --merge

Still not sure?  See the sample Docker "Hello World" below.

`Makefiles` to come and are currently a WIP include:

- docker-compose
- AWS
- git

*******************************************
Run the Sample Docker "Hello World" Project
*******************************************

To get help at any time::

    $ make -f sample/Makefile help

Docker "Hello World" Image Build
================================

::

    $ make -f sample/Makefile bi

Run the Container
=================

::

    $ make -f sample/Makefile run

Delete the Image
================

::

  $ make -f sample/Makefile rmi

***************************
Python Virtual Environments
***************************

To build a Python virtual environment, your dependencies to `requirements.txt` in the top level of you project directory::

  $ make -f sample/Makefile init

*****************
Command Reference
*****************

`makefile/docker.mk`
====================

Tag image built under version control with the `latest` tag::

    $ make tag

Remove dangling images::

    $ make rm-dangling-images
