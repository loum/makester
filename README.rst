#####################################################
Makester - Common Project Build/Management Components
#####################################################

Centralised repository for common tasks that you use everyday in your coding projects.

Created in response to a proliferation of disjointed Makefiles over the years.  Now, projects can follow a consistent infrastructure management pattern that is version controlled and easy to use.

If you use Docker, ``docker-compose`` or Python virtual environments regularly then read on.

*************
Prerequisites
*************

- `Docker <https://docs.docker.com/install/>`_

***************
Getting Started
***************

Get the code and change into the top level ``git`` project directory::

    $ git clone https://github.com/loum/makester.git && cd makester

.. note::

    Run all commands from the top-level directory of the ``git`` repository.

****************
Project Overview
****************

The ``Makester`` project layout features a grouping of ``Makefiles`` under the ``makefiles`` directory::

  $ tree makefiles/
  makefiles/
  ├── base.mk
  ├── docker.mk
  └── python-venv.mk

Each ``Makefile`` is a group of concerns for a particular project build/infrastructure component.  For example, ``makefiles/python-venv.mk`` has targets that allow you to create and manage Python virtual environments.

To use, add ``Makester`` as a submodule in your ``git`` project repository::

  $ git submodule add https://github.com/loum/makester.git

Create a ``Makefile`` at the top-level of your ``git`` project repository.

Include the required makefile targets into your ``Makefile``.  For example::

    include makester/makefiles/base.mk

.. note::

    Remember to regularly get the latest ``Makester`` code base::

        $ git submodule update --remote --merge

Still not sure?  See the sample Docker "Hello World" below.

``Makefiles`` to come and are currently a WIP include:

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

To build a Python virtual environment, add your dependencies to ``requirements.txt`` or ``setup.py`` in the top level of you project directory.

.. note::

   Both ``requirements.txt`` and ``setup.py`` for ``pip install`` are supported here.  Depending on your preference, create a target in your ``Makefile`` and chain either ``pip-requirements`` or ``pip-editable``.  For example, if your environment features a ``setup.py`` then create a new target called ``init`` (can be any meaningful target name you chose) as follows::

    init: pip-editable

Likewise, if you have a ``requirements.txt``::

    init: pip-requirements

Then, execute the ``init`` target::

  $ make -f sample/Makefile init

*****************
Command Reference
*****************

``makefile/python-venv.mk``
===========================

Display your environment Python setup::

   $ make py-versions

  pip-requirements     "clear-env"|"init-env" and build virtual environment deps from "requirements.txt"
  pip-editable         "clear-env"|"init-env" and build virtual environment deps from "setup.py"

Remove existing virtual environment::

   $ make clear-env

Build virtual environment::

   $ make init-env

``makefile/docker.mk``
======================

Tag image built under version control with the ``latest`` tag::

    $ make tag

Remove dangling images::

    $ make rm-dangling-images
