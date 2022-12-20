# Makester: Common Project Build and Management Tooling
- [Overview](#Overview)
- [Prerequisites](#Prerequisites)
  - [Extras for macOS](#Extras-for-macOS)
- [Getting Started](#Getting-Started)

## Overview
Makester is a [GNU make](https://www.gnu.org/software/make/manual/make.html) based Integrated Developer Platform that brings common tooling and techniques to your coding projects. Note that there is a heavy bias towards Linux, containerisation and Kubernetes to promote cloud-native capability. No, not cloud-native that locks you into cloud provider's services ...

Project documentation and detailed instructions can be found at the [Makester documenation site](https://loum.github.io/makester/).

## Prerequisites
- [Docker](https://docs.docker.com/install/)
- [GNU make](https://www.gnu.org/software/make/manual/make.html)

If using [Kubernetes Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/):
- [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

Optionally, install [kompose](https://kompose.io/installation/) if you would like to convert existing Docker Compose files into Kubernetes manifests.

### Extras for macOS
To develop Makester on macOS you will need to install these additional packages with [brew](https://brew.sh/):
```
brew install wget findutils coreutils
```
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
Next, prepare the Makester environment:
```
make py-install-makester
```

---
[top](#Makester-Common-Project-Build-and-Management-Tooling)
