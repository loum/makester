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

If using `Kubernetes Minikube <https://kubernetes.io/docs/setup/learning-environment/minikube/>`_:

- `Minikube <https://kubernetes.io/docs/tasks/tools/install-minikube/>`_
- `kubectll <https://kubernetes.io/docs/tasks/tools/install-kubectl/>`_
- `kompose <https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/#install-kompose>`_ if you would like to convert `docker-compose.yml` files to Kubernetes manifests

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
  ├── k8s.mk
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

- ``MAKESTER__SERVICE_NAME`` - a service identifier that defaults to ``MAKESTER__PROJECT_NAME``.  If ``MAKESTER__REPO_NAME`` is defined in your ``Makefile`` then ``MAKESTER__SERVICE_NAME`` becomes ``MAKESTER__REPO_NAME/MAKESTER__PROJECT_NAME``
- ``HASH`` - as per ``git rev-parse --help``.  The ``HASH`` value of your ``git`` branch allows you to uniquely identify each build revision within your project.  Once you merge your code changes back into the ``master`` branch, you can ``make tag-latest`` to tag the image with ``latest``.

.. note::

    ``MAKESTER__SERVICE_NAME`` is used extensively throughout Makester so you should use it within your ``Makefile`` targets.  Not happy with the defaults?  Then override ``MAKESTER__SERVICE_NAME`` at the top of your ``Makefile`` as follows::

        # Include overrides (must occur before include statements).
        MAKESTER__SERVICE_NAME := supa-cool-sdervice-name

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

Makester ``docker-compose``
===========================

`docker-compose <https://docs.docker.com/compose/>`_ is a great tool for managing your Docker container stack but a real pain when it comes to installing on your preferred platform.  Let ``pip`` manage the install and have one less thing to worry about ...

Combine ``makester-requirements`` with your Project's ``requirements.txt``
==========================================================================

::

    init: makester-requirements
        $(MAKE) pip-requirements

*************************************************
Makester Azure CLI Support in Virtual Environment
*************************************************

**Makester** can install the `Azure CLI <https://pypi.org/project/azure-cli/>`_ in your virtual environment by placing the following target in your ``Makefile``::

    azure-init: azure-requirements


******************
Makester Variables
******************

.. note::

    Makester global variables can be view any time with the ``vars`` target::

       $ make vars

- ``HASH`` - unique `git` branch identifier that allows you to identify each build revision within your project

The following Makester variables can be overridden with values placed at the top of your ``Makefile`` (before the ``include`` statements).

- ``MAKESTER__REPO_NAME`` - optional Docker Hub repository name (defaults empty)
- ``MAKESTER__PROJECT_NAME``
- ``MAKESTER__SERVICE_NAME``

- ``MAKESTER__VERSION`` - Control versioning (defaults to ``0.0.0``)
- ``MAKESTER__RELEASE_NUMBER`` - Control release number when versioning is unchanged (defaults to ``1``)


``makefile/docker.mk`` Variables
================================

- ``MAKESTER__CONTAINER_NAME`` - Control the name of your image container (defaults to ``my-container``)
- ``MAKESTER__IMAGE_TAG`` - (defaults to ``latest``)
- ``MAKESTER__RUN_COMMAND`` - override the Docker container ``run`` command initiated by ``make run``
- ``MAKESTER__COMPOSE_FILES`` - override the ``docker-compose`` ``-file`` switch (defaults to ``-f docker-compose.yml``
- ``MAKESTER__COMPOSE_RUN_CMD`` - override the ``docker-compose`` run command

*****************
Command Reference
*****************

``makefile/makester.mk``
========================

.. note::

    This Makefile should be included in all of your projects as a minimum.

Update your existing Git Submodules
-----------------------------------

::

    $ make submodule-update

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

Build Virtual Environment with Dependencies from ``requirements.txt``
---------------------------------------------------------------------

::

    $ make pip-requirements

Build Virtual Environment with Dependencies from  ``setup.py``
--------------------------------------------------------------

::

    $ make pip-editable

Remove Existing Virtual Environment
-----------------------------------

::

   $ make clear-env

Build Python Package from ``setup.py``
--------------------------------------

Write wheel package to -``-wheel-dir`` (defaults to ``~/wheelhouse``)::

    $ make package

Build Virtual Environment
-------------------------

::

   $ make init-env

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

Tag Docker image built under version control with the ``latest`` Tag::

    $ make tag

Tag Docker image with a custom versioning policy::

    $ make tag-version

.. note::

    ``make tag-version`` defaults to ``0,0,0-1`` but this can be overriden by setting ``MAKESTER__VERSION`` and ``MAKESTER__RELEASE_NUMBER`` in your ``Makefile``

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

``makefile/k8s.mk``
===================

Shakeout or debug your Docker image containers prior to deploying to Kubernetes.

.. note::

    All Kubernetes manifests are expected to be in the ``MAKESTER__K8_MANIFESTS`` directory (defaults to ``k8s/manifests``).

Kubernetes Minikube ``make mk-<minikube-target>``
-------------------------------------------------

Requires `Minikube <https://kubernetes.io/docs/tasks/tools/install-minikube/>`_.


Check Minikube Local Cluster Status
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    $ make mk-status

Start Minikube Locally and Create a Cluster (``docker`` driver)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    $ make mk-start

Access the Kubernetes Dashboard (Ctrl-C to stop)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    $ make mk-dashboard

Stop Minikube Local Cluster
^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    $ make mk-stop

Delete Minikube Local Cluster
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    $ make mk-del

Get Service Access Details
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note::

    Only applicable if ``LoadBalancer`` type is specified in your Kubernetes manifest.  Add this to your ``docker-compose.yml`` before converting::

      labels:
          kompose.service.type: LoadBalancer

::

    $ make mk-service

Kompose
-------

Requires `kompose <https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/#install-kompose>`_.

Convert config files from ``docker-compose.yml``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Write out new manifests to ``MAKESTER__K8_MANIFESTS`` (defaults to ``./k8s/manifests``).

::

    $ make konvert

Kubernetes ``kubectl`` ``make kube-<kubectl-target>``
-----------------------------------------------------

Requires `kubectll <https://kubernetes.io/docs/tasks/tools/install-kubectl/>`_.

.. warning::

    Care must be taken when managing mulitple Kubernetes contexts.  ``kubectl`` will operate against the active context.

Check Current ``kubectl`` Context
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    $ make kube-context

.. note::

    Current context name is delimited with the ``*``::

      CURRENT   NAME                CLUSTER             AUTHINFO                                                                NAMESPACE
                SupaAKSCluster      SupaAKSCluster      clusterUser_RESOURCE_GROUP_SupaAKSCluster
      *         minikube            minikube            minikube

Change ``kubectl`` Context
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    $ make kube-context-set MAKESTER__KUBECTL_CONTEXT=<context-name>

Change ``kubectl`` to the ``minikube`` Context
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    $ make kube-context-set

Create Kubernetes Resource(s)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Builds all manifestf files in ``MAKESTER__K8_MANIFESTS`` directory::

    $ make kube-apply

Delete Kubernetes Resource(s)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Deletes all manifestf files in ``MAKESTER__K8_MANIFESTS`` directory::

    $ make kube-del

View the Pods and Services
^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    $ make kube-get

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

``utils/templatester.py`` takes file path to ``template`` and renders the template against target variables.  The variables can be specified as a JSON document defined by ``--mapping``.

The ``template`` path needs to end with a ``.j2`` extension.  If the ``--write`` switch is provided then generated content will be output to the ``template`` less the ``.j2``.

A special custom filter ``env_override`` is available to bypass ``MAPPING`` values and source the environment for variable substitution.  Use the custom filter ``env_override`` in your template as follows::

    "test" : {{ "default" | env_override('CUSTOM') }}

Provided an environment variable as been set::

    export CUSTOM=some_value

The template will render::

    some_value

Otherwise::

    default

``utils/templatester.py`` example::

    # Create the Jinja2 template.
    cat << EOF > my_template.j2
    This is my CUSTOM variable value: {{ CUSTOM }}
    EOF
    # Template!
    CUSTOM=bananas 3env/bin/python utils/templatester.py --quiet my_template.j2

Outputs::

    This is my CUSTOM variable value: bananas

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
