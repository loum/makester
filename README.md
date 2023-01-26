# Makester: Common Project Build and Management Tooling
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Extras for macOS](#extras-for-macos)
- [Getting Started](#getting-started)
- [Running the Test Harness](#running-the-test-harness)

## Overview
Makester is a [GNU make](https://www.gnu.org/software/make/manual/make.html) based Integrated Developer Platform that brings common tooling and techniques to your coding projects. Note that there is a heavy bias towards Linux, containerisation and Kubernetes to promote cloud-native capability. No, not cloud-native that locks you into cloud provider's services ...

Refer to [Makester's documentation](https://loum.github.io/makester/) for detailed instructions.

## Prerequisites
- [Docker](https://docs.docker.com/install/)
- [GNU make](https://www.gnu.org/software/make/manual/make.html)
- Python 3 Interpreter. [We recommend installing pyenv](https://github.com/pyenv/pyenv)

If using [Kubernetes Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/):
- [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

Optionally, install [kompose](https://kompose.io/installation/) if you would like to convert existing Docker Compose files into Kubernetes manifests.

## Extras for macOS
### Dependencies
To develop Makester on macOS you will need to install these additional packages with [brew](https://brew.sh/):
```
brew install wget findutils coreutils
```

### Upgrading GNU Make
Follow [these notes](https://loum.github.io/makester/macos/#upgrading-gnu-make-macos) to get [GNU make](https://www.gnu.org/software/make/manual/make.html).


## Getting Started
Get the code and change into the top level `git` project directory:
```
git clone https://github.com/loum/makester.git && cd makester
```

> **_NOTE:_** Run all commands from the top-level directory of the `git` repository.

For first-time setup, prime the [Makester project](https://github.com/loum/makester.git):
```
git submodule update --init
```

Prepare the Makester environment:
```
make init
```

## Running the Test Harness
We use [bats-core](https://bats-core.readthedocs.io/en/stable/). To run the tests:
```
make tests
```

---
[top](#makester-common-project-build-and-management-tooling)
