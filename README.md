# Makester: Common Project Build and Management Tooling
- [Overview](#Overview)
- [Prerequisites](#Prerequisites)
- [Getting Started](#Getting-Started)
  - [Run the Sample Docker "Hello World" Project](#Run-the-Sample-Docker-"Hello-World"-Project)
- [Adding `Makester` to your Project's Git Repository](#Adding-`Makester`-to-your-Project's-Git-Repository)
  - [Makester Default Virtual Environment](#Makester-Default-Virtual-Environment)
- [Makester Tooling](#Makester-Tooling)
  - [`makefile/makester.mk`](#`makefile/makester.mk`)
  - [`makefiles/python-venv.mk`](#`makefiles/python-venv.mk`)
  - [`makefiles/compose.mk`](#`makefiles/compose.mk`)
  - [`makefile/docker.mk`](#`makefiles/docker.mk`)
  - [`makefile/k8s.mk`](#`makefiles/k8s.mk`)
  - [`makefile/versioning.mk`](#`makefiles/versioning.mk`)
   - [`makefile/kompose.mk`](#`makefiles/kompose.mk`)
- [Makester Utilities](#Makester-Utilities)
- [Makester Recipes](#Makester-Recipes)

## Overview
Makester is aimed to be a centralised, reusable tool kit for tasks that you use regularly in your projects. Makester was inspired by [Modern Make](https://makefile.site/) and created in response to a proliferation of disjointed Makefiles. Now, projects can follow a consistent infrastructure management pattern that is version controlled and easy to use.

If you use Python, Docker or Kubernetes daily then read on.

The `Makester` project layout features a grouping of makefiles under the `makefiles` directory:
```
tree makefiles/
```
```
makefiles/
├── compose.mk
├── docker.mk
├── k8s.mk
├── makester.mk
└── python-venv.mk
```
Each `Makefile` is a group of concerns for a particular project build/infrastructure component. For example, `makefiles/python-venv.mk` has targets that allow you to create and manage Python virtual environments.

Still not sure? Try to [Run the Sample Docker "Hello World" Project](#Run-the-Sample-Docker-"Hello-World"-Project).

## Prerequisites
- [Docker](https://docs.docker.com/install/)
- [GNU make](https://www.gnu.org/software/make/manual/make.html)

If using [Kubernetes Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/):
- [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

Optionally, install [kompose](https://kompose.io/installation/) if you would like to convert existing Docker Compose files into Kubernetes manifests.

## Getting Started
Get the code and change into the top level `git` project directory:
```
git clone https://github.com/loum/makester.git && cd makester
```
> **_NOTE:_** Run all commands from the top-level directory of the `git` repository.

### Run the Sample Docker "Hello World" Project
To get help at any time:
```
make -f sample/Makefile help
```
Build a Docker image based off the "Hello World" image:
```
make -f sample/Makefile image-build
```
```
/usr/bin/docker build -t supa-cool-repo/my-project:99296c8 sample
Sending build context to Docker daemon  3.072kB
Step 1/1 : FROM hello-world
 ---> d1165f221234
Successfully built d1165f221234
Successfully tagged supa-cool-repo/my-project:99296c8
```
To run your new `supa-cool-repo/my-project:99296c8` container:
```
make -f sample/Makefile run
```
Finally, to clean up you can delete the `supa-cool-repo/my-project:99296c8` image:
```
make -f sample/Makefile irm
```
## Adding `Makester` to your Project's Git Repository

 1. Add `Makester` as a submodule in your `git` project repository:
```
git submodule add https://github.com/loum/makester.git
```
> **_NOTE:_** `git submodule add` will only `fetch` the submodule folder without any content. For first time initialisation (`pull` the submodule):
```
git submodule update --init --recursive
```
 2. Create a `Makefile` at the top-level of your `git` project repository. Not sure what that means? Then just copy over the [sample Makefile](https://github.com/loum/makester/blob/main/sample/Makefile>) and tweak the targets to suit.
 3. Include the required makefile targets into your `Makefile`. For example:
```
include makester/makefiles/makester.mk
```
> **_NOTE:_** Remember to regularly get the latest `Makester` code base:
```
git submodule update --remote --merge
```
or, as a convenience:
```
make submodule-update
```
### Makester Variables
The standard [GNU Makefile variable](https://www.gnu.org/software/make/manual/html_node/Using-Variables.html) convention is adhered to within the project. Makester introduces special purpose variables are denoted as `MAKESTER__`. Makester will attempt to provide sane defaults to get you started. However, it is recommended that you override these values in your own project's Makefile to provide more informative context.

Makester special purpose variable values can be viewed any time with the `vars` target:
```
make vars
```
A description of the Makester special purpose variables follows:
- `MAKESTER__PROJECT_NAME`: the name of the project. Defaults to the current working directory's basename.
- `MAKESTER__SERVICE_NAME`: a service identifier that defaults to `MAKESTER__PROJECT_NAME`. This can be used to target your container repository and identify your image.
	- If `MAKESTER__REPO_NAME` is defined in your `Makefile` then `MAKESTER__SERVICE_NAME` becomes `MAKESTER__REPO_NAME/MAKESTER__PROJECT_NAME`. For example `supa-cool-repo/my-project` is achieved with the following:
    ```
    MAKESTER__REPO_NAME := supa-cool-repo
    MAKESTER__PROJECT_NAME := my-project
    ```
  > **_NOTE:_** `MAKESTER__SERVICE_NAME` is used extensively throughout `Makester` so you should use it within your   `Makefile` targets. Not happy with the defaults? Then override `MAKESTER__SERVICE_NAME` at the top of your `Makefile`   as follows:
  > ```
  > # Include overrides (must occur before include statements).
  > MAKESTER__SERVICE_NAME := supa-cool-service-name
  > ```

- `HASH`: as per `git rev-parse --help`. The `HASH` value of your `git` branch allows you to uniquely identify each build revision within your project. Once you merge your code changes back into the `main` branch, you can `make tag-latest` to tag the image with `latest`.
- `MAKESTER__VERSION`: Manual versioning control (defaults to `0.0.0`).
- `MAKESTER__RELEASE_NUMBER`: Manual release number control when `MAKESTER__VERSION` is unchanged (defaults to `1`).
- `MAKESTER__RELEASE_VERSION`: Advanced versioning control that provides a hook into an autonomous versioning facility (for example, [GitVersion](https://gitversion.net/docs/)).
- `MAKESTER__LOCAL_IP`: Platform independent way to get the local host's IP address.
- `MAKESTER__WORK_DIR`: Working area that Makester uses to store information (defaults to `$PWD/.makester`).
  > **_NOTE:_** Be sure to add the location of `MAKESTER__WORK_DIR` into your project's `.gitignore`.

- `MAKESTER__K8S_MANIFESTS`: location of your project's Kubernetes manifests (defaults to `$MAKESTER__WORK_DIR/k8s/manifests`).

### Makester Default Virtual Environment
`Makester` provides a Python virtual environment that adds dependencies that are used by `Makester` to get things done. First, you need to place the following target in your `Makefile`:
```
makester-init: makester-requirements
```
To then build the Python virtual environment under the directory `3env`:
```
make makester-init
```
## Makester Tooling
### `makefile/makester.mk`
> **_NOTE:_** This Makefile should be included in all of your projects as a minimum.

To use add `include makester/makefiles/makester.mk` to your `Makefile`.

#### Command Reference
##### Update your existing Git Submodules
```
make submodule-update
```
### Makester `makefiles/python-venv.mk`
To use add `include makester/makefiles/python-venv.mk` to your `Makefile`.

To build a project-purposed Python virtual environment, add your dependencies to `requirements.txt` or `setup.py` in the top level of you project directory.

> **_NOTE:_** Both `requirements.txt` and `setup.py` for `pip install` are supported here. Depending on your preference, create a target in your `Makefile` and chain either `pip-requirements` or `pip-editable`. For example, if your environment features a `setup.py` then create a new target called `init` (can be any meaningful target name you choose) as follows:
```
init: pip-editable
```
Likewise, if you have a `requirements.txt`:
```
init: pip-requirements
```
Then, execute the `init` target:
```
make -f sample/Makefile init
```
It is also possible to combine `makester-requirements` with your Project's `requirements.txt`
```
init: makester-requirements
	$(MAKE) pip-requirements
```
#### Command Reference
##### Display your Local Environment's Python Setup
```
make py-versions
```
Sample output:
```
python3 version: Python 3.6.10
python3 minor: 6
path to python3 executable: /home/lupco/.pyenv/shims/python3
python3 virtual env command: /home/lupco/.pyenv/shims/python3 -m venv
python2 virtual env command:
virtual env tooling: /home/lupco/.pyenv/shims/python3 -m venv
```
##### Build Virtual Environment with Dependencies from `requirements.txt`
```
make pip-requirements
```
##### Build Virtual Environment with Dependencies from `setup.py`
```
make pip-editable
```
##### Remove Existing Virtual Environment
```
make clear-env
```
##### Build Python Package from `setup.py`
Write wheel package to -`-wheel-dir` (defaults to `~/wheelhouse`):
```
make package
```
##### Build Virtual Environment
```
make init-env
```
##### Invoke the Python REPL
```
make py
```
### `makefiles/compose.mk`
To use add `include makester/makefiles/compose.mk` to your `Makefile`.

Traditional Makester capability has supported
[docker compose](https://docs.docker.com/engine/reference/commandline/compose/) capability as a basic
multi-container orchestration facility. Makester strategy is to move more into the Kubernetes space so support
for `makefiles/compose.mk` will continue to diminish over time.

> **_NOTE:_** Support for PyPI `docker-compose` has been completely removed as there does not appear to be
a roadmap within that project to move to [docker compose V2](https://docs.docker.com/compose/compose-v2/).

As of [Moby 20.10.13](https://github.com/moby/moby/releases/tag/v20.10.13), [docker compose V2](https://docs.docker.com/compose/compose-v2/) is integrated into the Docker CLI. This means that we do not need to support the installation of the standalone [docker-compose](https://docs.docker.com/compose/install/other/).

#### Variables
> **_NOTE_**: Makester `makefile/compose.mk` assumes a `docker-compose.yml` file exists in the top level directory of the project repository by default. However, this can overridden by setting the `MAKESTER__COMPOSE_FILES` parameter:
```
MAKESTER__COMPOSE_FILES = -f docker-compose-supa.yml
```
If you need more control over `docker-compose`, then override the `MAKESTER__COMPOSE_RUN_CMD` parameter in your `Makefile`. For example, to specify the verbose output option:
```
MAKESTER__COMPOSE_RUN_CMD ?= SERVICE_NAME=$(MAKESTER__PROJECT_NAME) HASH=$(HASH)\
 $(MAKESTER__DOCKER_COMPOSE)\
 --verbose\
 $(MAKESTER__COMPOSE_FILES) $(COMPOSE_CMD)
```
- `MAKESTER__COMPOSE_FILES`: override the `docker-compose` `-file` switch (defaults to `-f docker-compose.yml`
- `MAKESTER__COMPOSE_RUN_CMD`: override the `docker-compose` run command

#### Command Reference
##### Build your Compose Stack
```
make compose-up
```
##### Destroy your Compose Stack
```
make compose-down
```
##### Dump your Compose Stack's Configuration
```
make compose-config
```
#### Variables
#### Command Reference

### `makefile/docker.mk`
#### Variables
- `MAKESTER__CONTAINER_NAME`: Control the name of your image container (defaults to `my-container`)
- `MAKESTER__IMAGE_TAG`: (defaults to `latest`)
- `MAKESTER__RUN_COMMAND`: override the Docker container `run` command initiated by `make run`
- `MAKESTER__BUILD_COMMAND`: override the command line options to `docker build` or `docker buildx build` to have more fine-grained control over the container image build process. For example, the following snippet overrides the image tag:
   ```
  MAKESTER__BUILD_COMMAND := -t $(MAKESTER__SERVICE_NAME):$(HASH) .
  ```

#### Command Reference
##### Build your Docker Image
```
make image-build
```
Alternatively, leverage the features provided by [BuildKit](https://docs.docker.com/build/buildkit/):
```
make image-buildx
```
##### Run your Docker Images as a Container
```
make run
```
The `run` target can be controlled in your `Makefile` by overriding the `MAKESTER__RUN_COMMAND` parameter. For example:
```
MAKESTER__RUN_COMMAND := $(MAKESTER__DOCKER) run --rm -d --name $(MAKESTER__CONTAINER_NAME) $(MAKESTER__SERVICE_NAME):$(HASH)
```
##### Tag Docker Image with the `latest` Tag
```
make tag
```
##### Tag Docker image with a Custom Versioning Policy
```
make tag-version
```
Version defaults to `0.0.0-1` but this can be overridden by setting `MAKESTER__VERSION` and `MAKESTER__RELEASE_NUMBER` in your `Makefile`. Alternatively, to align with your preferred tagging convention, override the `MAKESTER__IMAGE_TAG` parameter. For example:
```
make tag MAKESTER__IMAGE_TAG=supa-tag-01
```
##### Remove your Docker Image
```
make rm-image
```
##### Remove Dangling Docker Images
```
make rm-dangling-images
```
### `makefile/k8s.mk`
To use add `include makester/makefiles/k8s.mk` to your `Makefile`.

Shakeout or debug your Docker image containers prior to deploying to Kubernetes.
> **_NOTE_**: All Kubernetes manifests are expected to be in the `MAKESTER__K8_MANIFESTS` directory (defaults to `$MAKESTER__WORK_DIR/k8s/manifests`).

> **_WARNING:_** Care must be taken when managing mulitple Kubernetes contexts. `kubectl` will operate against the active context.

#### Variables
#### Command Reference
##### Check Minikube Local Cluster Status
```
make mk-status
```
##### Start Minikube Locally and Create a Cluster (`docker` driver)
```
make mk-start
```
##### Access the Kubernetes Dashboard (Ctrl-C to stop)
```
make mk-dashboard
```
##### Stop Minikube Local Cluster
```
make mk-stop
```
##### Delete Minikube Local Cluster
```
make mk-del
```
##### Get Service Access Details
> **_NOTE:_** Only applicable if `LoadBalancer` type is specified in your Kubernetes manifest.
```
make mk-service
```
##### Check Current `kubectl` Context
```
make kube-context
```
> **_NOTE:_** Current context name is delimited with the `*`:
> ```
>      CURRENT   NAME                CLUSTER             AUTHINFO                                                                NAMESPACE
>                SupaAKSCluster      SupaAKSCluster      clusterUser_RESOURCE_GROUP_SupaAKSCluster
>      *         minikube            minikube            minikube
> ```
##### Change `kubectl` Context
```
make kube-context-set MAKESTER__KUBECTL_CONTEXT=<context-name>
```
##### Change `kubectl` to the `minikube` Context
```
make kube-context-set
```
##### Create Kubernetes Resource(s)
Builds all manifest files in `MAKESTER__K8_MANIFESTS` directory:
```
make kube-apply
```
##### Delete Kubernetes Resource(s)
Deletes all manifest files in `MAKESTER__K8_MANIFESTS` directory:
```
make kube-del
```
##### View the Pods and Services
```
make kube-get
```
### `makefile/versioning.mk`
To use add `include makester/makefiles/versioning.mk` to your `Makefile`.

> **_NOTE:_** `makefile/versioning.mk` uses the [GitVersion Docker image](https://hub.docker.com/r/gittools/gitversion). As such, `makefile/docker.mk` also needs to be added to your `Makefile`. Makester will prompt you if you forget:
> ```
> ### Add the following include statement to your Makefile
> include makester/makefiles/docker.mk
> makefiles/versioning.mk:8: *** ### missing include dependency.  Stop.
> ```

`makefile/versioning.mk` extends the basic versioning capabilities provided by `MAKESTER__VERSION` and `MAKESTER__RELEASE_NUMBER` by leveraging [GitVersion](https://gitversion.net/docs/). In brief, `makefile/versioning.mk` allows a degree of versioning autonomy based on your Git history.

`makefile/versioning.mk` works with the special variable hook `makefiles/makester.mk:MAKESTER__RELEASE_VERSION` when the `release-version` target is added to your project's `Makefile`.
> **_NOTE:_** `release-version` creates static output files under Makester's `MAKESTER__WORK_DIR`. These are namely:
> - `$MAKESTER__WORK_DIR/release-version`
> - `$MAKESTER__WORK_DIR/versioning`

If version currency is important for a particular function then you can chain the `release-version` target to any target within your `Makefile`. For example, when you are building a fresh Docker image, the following recipe will ensure that a new `MAKESTER__RELEASE_NUMBER` is generated just prior to the Docker image build process:
> ```
> image-build: release-version
> ```
`makefile/versioning.mk` checks for a `GitVersion.yml` at the top level of your project but will default to GitVersion's internal default if one is not provided. To see the default release variables and values, run:
```
make release-version
```
... and check the contents of `$PWD/.makester/versioning`.

In certain cases, GitVersion's defaults may be all that your project needs. But code versioning can be a touchy subject. Customising your own `GitVersion.yml` will give you full control over this facility. Follow the [GitVersion configuration guide](https://gitversion.net/docs/reference/configuration) to initialise your own `GitVersion.yml`. Makester also provides a [working, sample `GitVersion.yml`](https://github.com/loum/makester/blob/main/sample/GitVersion.yml) that is geared toward Python projects.

#### Variables
- `MAKESTER__GITVERSION_CONFIG`: optionally specify the location of your project's `GitVersion.yml` (defaults to `GitVersion.yml` at the top level of the project.
- `MAKESTER__GITVERSION_VARIABLE`: the GitVersion release variable value filter (defaults to `AssemblySemFileVer`).
- `MAKESTER__GITVERSION_VERSION`: the GitVersion docker image version (defaults to `latest`).

#### Command Reference
##### `make versioning-help`
Displays the `makefile/versioning.mk` usage message.

##### `make gitversion`
Displays the GitVersion usage message.

##### `make release-version`
Filtered GitVersion variables against `MAKESTER__GITVERSION_VARIABLE` (defaults to `AssemblySemFileVer`). For example:
```
### Filtering GitVersion variable: AssemblySemFileVer
### MAKESTER__RELEASE_VERSION: "0.1.0.0"
```
##### `make gitversion-clear`
Clear the temporary GitVersion files from `$MAKESTER__WORK_DIR`

### `makefile/kompose.mk`
Convert Docker Compose artifacts into container orchestrator manifests.

`makefile/kompose.mk` leverages (Kubernetes `kompose`)[https://kompose.io/] which is a handy tool if you are moving to Kubernetes from Docker Compose.

#### Variables
- `MAKESTER__COMPOSE_K8S_EPHEMERAL`: optionally specify the location of your project's `docker-compose.yml` (defaults to `docker-compose.yml` at the top level of the project.
- `MAKESTER__K8S_MANIFESTS`: Kubernetes manifest target output (defaults to `$MAKESTER__WORK_DIR/k8s/manifests`).

#### Command Reference
##### `make kompose-help`
Displays the `makefile/kompose.mk` usage message.

##### `make kompose`
Translate Docker Compose to Kubernetes manifests.

## Makester Utilities
### `utils/waitster.py`
Wait until dependent service is ready:
```
3env/bin/python utils/waitster.py
```
```
usage: waitster.py [-h] -p PORT [-d DETAIL] host

Backoff until all ports ready

positional arguments:
  host                  Connection host

optional arguments:
  -h, --help            show this help message and exit
  -p PORT, --port PORT  Backoff port number until ready
  -d DETAIL, --detail DETAIL
                        Meaningful description for backoff port
```
### `utils/templatester.py`
Template against environment variables or optional JSON values (`--mapping` switch):
```
3env/bin/python utils/templatester.py --help
```

```
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
```
`utils/templatester.py` takes file path to `template` and renders the template against target variables. The variables can be specified as a JSON document defined by `--mapping`.

The `template` path needs to end with a `.j2` extension. If the `--write` switch is provided then generated content will be output to the `template` less the `.j2`.

A special custom filter `env_override` is available to bypass `MAPPING` values and source the environment for variable substitution. Use the custom filter `env_override` in your template as follows:
```
"test" : {{ "default" | env_override('CUSTOM') }}
```

Provided an environment variable as been set:
```
export CUSTOM=some_value
```
The template will render:
```
some_value
```
Otherwise:
```
default
```
`utils/templatester.py` example:
```
# Create the Jinja2 template.
cat << EOF > my_template.j2
This is my CUSTOM variable value: {{ CUSTOM }}
EOF
# Template!
CUSTOM=bananas 3env/bin/python utils/templatester.py --quiet my_template.j2
```
Outputs:
```
This is my CUSTOM variable value: bananas
```
## Makester Recipes
### Integrate `utils/backoff.py` with `makefile/compose.mk` in your Makefile
The following recipe defines a *backoff* strategy with `docker-compose` in addition to adding an action to run the initialisation script, `init-script.sh`:
```
backoff:
    @$(PYTHON) makester/utils/waitster.py -d "HiveServer2" -p 10000 localhost
    @$(PYTHON) makester/utils/waitster.py -d "Web UI for HiveServer2" -p 10002 localhost

local-build-up: compose-up backoff
    @./init-sript.sh
```
### Provide Multiple `docker-compose` `up`/`down` Targets
Override `MAKESTER__COMPOSE_FILES` Makester parameter to customise multiple build/destroy environments:
```
test-compose-up: MAKESTER__COMPOSE_FILES = -f docker-compose.yml -f docker-compose-test.yml
test-compose-up: compose-up

dev-compose-up: MAKESTER__COMPOSE_FILES = -f docker-compose.yml -f docker-compose-dev.yml
dev-compose-up: compose-up
```
> **_NOTE:_** Remember to provide the complimentary `docker-compose` `down` targets in your `Makefile`.

---
[top](#Makester-Common-Project-Build-and-Management-Tooling)
