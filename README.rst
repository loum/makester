#####################################################
Makester - Common Project Build/Management Components
#####################################################

Centralised repository for common tasks that you use everyday in your coding projects.

Created in response to a proliferation of disjointed Makefiles over the years.  Now, projects can follow a consistent infrastructure management pattern that is version controlled and easy to use.

If you're into `3 musketeers <https://3musketeers.io/>`_ and use Docker, ``docker-compose`` or Python virtual environments and ``make`` regularly then read on.

Still not sure?  Try to `Run the Sample Docker "Hello World" Project`_.

*************
Prerequisites
*************

- `Docker <https://docs.docker.com/install/>`_
- `GNU make <https://www.gnu.org/software/make/manual/make.html>`_

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

The **Makester** project layout features a grouping of makefiles under the ``makefiles`` directory::

  $ tree makefiles/
  makefiles/
  ├── compose.mk
  ├── docker.mk
  ├── makester.mk
  └── python-venv.mk

Each ``Makefile`` is a group of concerns for a particular project build/infrastructure component.  For example, ``makefiles/python-venv.mk`` has targets that allow you to create and manage Python virtual environments.

Adding **Makester** to your Git Repository
==========================================

#. Add **Makester** as a submodule in your ``git`` project repository::

   $ git submodule add https://github.com/loum/makester.git

   .. note::

      ``git submodule add`` will only ``fetch`` the submodule folder without any content.  For first time initialisation (``pull`` the submodule)::
           
         $ git submodule update --init --recursive

#. Create a ``Makefile`` at the top-level of your ``git`` project repository.

#. Include the required makefile targets into your ``Makefile``.  For example::

      include makester/makefiles/base.mk

.. note::

    Remember to regularly get the latest ``Makester`` code base::

        $ git submodule update --remote --merge
    
    or, as a convenience::

        $ make submodule-update

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

******************************
Using Makester in your Project
******************************

Add a ``Makefile`` to the top level of your project.  Not sure what that means?  Then just copy over `the sample Makefile <https://github.com/loum/makester/blob/master/sample/Makefile>`_ and tweak the targets to suit.

Some important parameters to note:

- ``DOCKER`` - path to your local Docker executable
- ``MAKESTER__SERVICE_NAME`` - an image identifier built from the Docker repository name (defaults to ``makester``) and a customisable project name (defaults to the project's parent directory).  For example, ``makester/sample``
- ``HASH`` - as per ``git rev-parse --help``.  The ``HASH`` value of your ``git`` branch allows you to uniquely identify each build revision within your project.  Once you merge your code changes back into the ``master`` branch, you can ``make tag`` to ``latest``.

.. note::

    ``MAKESTER__SERVICE_NAME`` is used extensively throughout Makester so you should use it within your ``Makefile`` targets.  Not happy with the defaults?  Then override them at the top of your ``Makefile`` as follows::

        # Include overrides (must occur before include statements).
        MAKESTER__REPO_NAME := supa-cool-repo
        MAKESTER__PROJECT_NAME := my-project
        MAKESTER__CONTAINER_NAME := mega-container

.. note::

    ``MAKESTER__REPO_NAME`` is optional.

``MAKESTER__CONTAINER_NAME`` allows you to control the name of the running container launched against your Docker image.

***************************
Python Virtual Environments
***************************

.. note::

    Add ``include makester/makefiles/python-venv.mk`` to your ``Makefile``

To build a Python virtual environment, add your dependencies to ``requirements.txt`` or ``setup.py`` in the top level of you project directory.

.. note::

   Both ``requirements.txt`` and ``setup.py`` for ``pip install`` are supported here.  Depending on your preference, create a target in your ``Makefile`` and chain either ``pip-requirements`` or ``pip-editable``.  For example, if your environment features a ``setup.py`` then create a new target called ``init`` (can be any meaningful target name you choose) as follows::

    init: pip-editable
    
   Likewise, if you have a ``requirements.txt``::

    init: pip-requirements

Then, execute the ``init`` target::

  $ make -f sample/Makefile init

************************************
Makester Default Virtual Environment
************************************

**Makester** provides a default virtual environment that can be invoked by placing the following target in your ``Makefile``::

    makester-init: makester-requirements

``makester-requirements`` install the following libraries:

Makester docker-compose
=======================

`docker-compose <https://docs.docker.com/compose/>`_ is a great tool for managing your Docker container stack but a real pain when it comes to installing on your preferred platform.  Let ``pip`` manage the install and have one less thing to worry about ...

Combine ``makester-requirements`` with your Project's ``requirements.txt``
==========================================================================

::

    init: makester-requirements
        make pip-requirements

****************************
Makester Important Variables
****************************

These can be overridden with values placed at the top of your ``Makefile`` (before the ``include`` statements)

- ``HASH`` - unique `git` branch identifier that allows you to identify each build revision within your project
- ``MAKESTER__REPO_NAME`` - optional Docker Hub repository name (defaults empty)
- ``MAKESTER__PROJECT_NAME``
- ``MAKESTER__SERVICE_NAME``
- ``MAKESTER__CONTAINER_NAME`` - Control the name of your image container (defaults to ``my-container``)
- ``MAKESTER__IMAGE_TAG`` - (defaults to ``latest``)
- ``MAKESTER__RUN_COMMAND`` - override the Docker container ``run`` command initiated by ``make run``
- ``MAKESTER__COMPOSE_FILES`` - override the ``docker-compose`` ``-file`` switch (defaults to ``-f docker-compose.yml``
- ``MAKESTER__COMPOSE_RUN_CMD`` - override the ``docker-compose`` run command

*****************
Command Reference
*****************

``makefile/python-venv.mk``
===========================

Display your Local Environment's Python Setup
---------------------------------------------

::

   $ make py-versions
   python3 version: Python 3.6.10
   python3 minor: 6
   path to python3 executable: /home/lupco/.pyenv/shims/python3
   python3 virtual env command: /home/lupco/.pyenv/shims/python3 -m venv
   python2 virtual env command:
   virtual env tooling: /home/lupco/.pyenv/shims/python3 -m venv

Remove Existing Virtual Environment
-----------------------------------

::

   $ make clear-env

Build Virtual Environment
-------------------------

::

   $ make init-env

``makefile/makester.mk``
========================

.. note::

    This Makefile should be included in all of your projects as a minimum.

Update your existing Git Submodules
-----------------------------------

::

    $ make submodule-update

``makefile/docker.mk``
======================

Build your Docker Image
-----------------------

::

    $ make build-image

The ``build-image`` target can be controlled by overrding the ``MAKESTER__BUILD_COMMAND`` parameter in your ``Makefile``.  For example::

    MAKESTER__BUILD_COMMAND := $(DOCKER) build -t $(MAKESTER__SERVICE_NAME):$(HASH) .

Run your Docker Images as a Container
-------------------------------------

::

    $ make run

The ``run`` target can be controlled in your ``Makefile`` by overriding the ``MAKESTER__RUN_COMMAND`` parameter.  For example::

    MAKESTER__RUN_COMMAND := $(DOCKER) run --rm -d --name $(MAKESTER__CONTAINER_NAME) $(MAKESTER__SERVICE_NAME):$(HASH)

Tag Docker Image built under version control with the ``latest`` Tag::

    $ make tag

Alternatively, to align with your preferred tagging convention, override the ``MAKESTER__IMAGE_TAG`` parameter::

    $ make tag MAKESTER__IMAGE_TAG=supa-tag-01

Remove your Docker Image
------------------------

::

    $ make rm-image

Remove Dangling Docker Images
-----------------------------

::

    $ make rm-dangling-images

``makefile/compose.mk``
=======================

Follow instructions under the `Makester docker-compose`_ heading to see how Makester can make ``docker-compose`` available in your project.

Build your infrastructure stack with `docker-compose <https://docs.docker.com/compose/>`_.

.. note::

    Makester ``makefile/compose.mk`` assumes a ``docker-compose.yml`` file exists in the top level directory of the project repository by default.  However, this can overriden by setting the ``MAKESTER__COMPOSE_FILES`` parameter::

        MAKESTER__COMPOSE_FILES = -f docker-compose-supa.yml

Build your Compose Stack
------------------------

::

    $ make compose-up

Destroy your Compose Stack
--------------------------

::

    $ make compose-down

Dump your Compose Stack's Configuration
---------------------------------------

::

    $ make compose-config

If you need more control over ``docker-compose``, the ``docker-compose`` command can be controlled in your ``Makefile`` by overriding the ``MAKESTER__COMPOSE_RUN_CMD`` parameter.  For example, to specify the verbose output option::

    MAKESTER__COMPOSE_RUN_CMD ?= SERVICE_NAME=$(MAKESTER__PROJECT_NAME) HASH=$(HASH)\
      $(DOCKER_COMPOSE)\
     --verbose\
     $(MAKESTER__COMPOSE_FILES) $(COMPOSE_CMD)

******************
Makester Utilities
******************

``utils/waitster.py``
=====================

Wait until dependent service is ready::

    $ 3env/bin/python utils/waitster.py
    usage: waitster.py [-h] -p PORT [-d DETAIL] host
    
    Backoff until all ports ready
    
    positional arguments:
      host                  Connection host
    
    optional arguments:
      -h, --help            show this help message and exit
      -p PORT, --port PORT  Backoff port number until ready
      -d DETAIL, --detail DETAIL
                            Meaningful description for backoff port

``utils/templatester.py``
=========================

Template against environment variables or optional JSON values (``--mapping`` switch)::

    $ 3env/bin/python utils/templatester.py --help
    usage: templatester.py [-h] [-f FILTER] [-m MAPPING] [-w] [-q] template
    
    Set Interpreter values dynamically
    
    positional arguments:
      template              Path to Jinja2 template (absolute, or relative to user home)
    
    optional arguments:
      -h, --help            show this help message and exit
      -f FILTER, --filter FILTER
                            Environment variable filter (ignored when mapping is taken from JSON file)
      -m MAPPING, --mapping MAPPING
                            Optional path to JSON mappings (absolute, or relative to user home).
      -w, --write           Write out templated file alongside Jinja2 template
      -q, --quiet           Disable logs to screen (to log level "ERROR")

****************
Makester Recipes
****************

Integrate ``utils/backoff.py`` with ``makefile/compose.mk`` in your Makefile
============================================================================

The following recipe defines a *backoff* strategy with ``docker-compose`` in addition to adding an action to run the initialisation script, ``init-script.sh``::

    backoff:
        @$(PYTHON) makester/utils/waitster.py -d "HiveServer2" -p 10000 localhost
        @$(PYTHON) makester/utils/waitster.py -d "Web UI for HiveServer2" -p 10002 localhost
    
    local-build-up: compose-up backoff
        @./init-sript.sh

Provide Multiple ``docker-compose`` ``up``/``down`` Targets
===========================================================

Override ``MAKESTER__COMPOSE_FILES`` Makester parameter to customise multiple build/destroy environments::

    test-compose-up: MAKESTER__COMPOSE_FILES = -f docker-compose.yml -f docker-compose-test.yml
    test-compose-up: compose-up
    
    dev-compose-up: MAKESTER__COMPOSE_FILES = -f docker-compose.yml -f docker-compose-dev.yml
    dev-compose-up: compose-up

.. note::

    Remember to provide the complimentary ``docker-compose`` ``down`` targets in your ``Makefile``.
