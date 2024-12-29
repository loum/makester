# Makester

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Extras for macOS](#extras-for-macos)
- [Getting Started](#getting-started)
- [Running the Test Harness](#running-the-test-harness)

## Overview

Makester is a [GNU make](https://www.gnu.org/software/make/manual/make.html) based integrated developer platform that brings common tooling and techniques to your coding projects. Note that there is a heavy bias towards Linux, containerisation and Kubernetes to promote cloud-native capability. No, not cloud-native that locks you into cloud provider's services ...

Refer to [Makester's documentation](https://loum.github.io/makester/) for detailed instructions.

## Prerequisites

- [Docker](https://docs.docker.com/install/)
- [GNU make](https://www.gnu.org/software/make/manual/make.html)
- Python 3 Interpreter. [We recommend installing pyenv](https://github.com/pyenv/pyenv)

If using [Kubernetes Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/):

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- At least one of the following minimal Kubernetes installations:
  - [MicroK8s](https://microk8s.io/#install-microk8s)
  - [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube)

If using [Terraform](https://developer.hashicorp.com/terraform), we recommend installing [tfenv](https://github.com/tfutils/tfenv).

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

### Operating System Compatibility

| O/S            | Status |
| :------------- | :----: |
| Linux          |   ✅   |
| macOS          |   ✅   |
| Windows        |   ❌   |
| Windows (WSL2) |   ✅   |

### Basic Installation

Makester is installed by running one of the following commands in your terminal. You can install this via the
command-line with either `curl`, `wget` or another similar tool.

| Method    | Command                                                                                           |
| :-------- | :------------------------------------------------------------------------------------------------ |
| **curl**  | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/loum/makester/main/tools/install.sh)"`     |
| **wget**  | `sh -c "$(wget -O- https://raw.githubusercontent.com/loum/makester/main/tools/install.sh)"`       |
| **fetch** | `sh -c "$(fetch -o - https://raw.githubusercontent.com/loum/makester/main/tools/install.sh)"`     |

## Running the Test Harness

We use [bats-core](https://bats-core.readthedocs.io/en/stable/). To run the tests:

```
make tests
```

______________________________________________________________________

[top](#makester)
