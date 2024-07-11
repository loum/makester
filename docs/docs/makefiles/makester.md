# Makester

The Makester Makefile, `makester/makefiles/makester.mk` is the core interface to Makester
capabilities. To start using Makester, add the following `include` into your `Makefile`:
``` sh
include makester/makefiles/makester.mk
```

To validate Makester, run the `makester-help` target and ensure there are no errors:
``` sh
make makester-help
```

## Command Reference

### Display the Makester Variables
Makester context is driven by environment variables. Most of these variables can be overriden to
suit your particular use cases.

``` sh title="Display the state of the Makester variables."
make vars
```

### Add a Sample `.gitignore` to your Project
Adds a `.gitignore` under `<MAKESTER__PROJECT_DIR>`. Uses the
[Makester sample `.gitignore`](https://github.com/loum/makester/blob/main/resources/project.gitignore)
as a starting point.
``` sh
make makester-gitignore
```

### Add an MIT Licence to your Project
Add an [MIT license](https://en.wikipedia.org/wiki/MIT_License){target="_blank"}
under `<MAKESTER__PROJECT_DIR>`. You will need to manually adjust the `<year>`
and `<copyright holders>`:
``` sh
make makester-mit-license
```

### Update your existing Git Submodules
``` sh
make submodule-update
```

## Makester Variables
The standard [GNU Makefile variable](https://www.gnu.org/software/make/manual/html_node/Using-Variables.html)
convention is adhered to within the project. Makester introduces special purpose variables are denoted as
`MAKESTER__<VARIABLE_NAME>`. Makester will attempt to provide sane defaults to get you started. However, it
is recommended that you override these values in your own project's Makefile to provide more informative context.

Makester special purpose variable values can be viewed any time with the `vars` target:
``` sh
make vars
```

A description of the Makester special purpose variables follows:
### `MAKESTER__PROJECT_NAME`
The name of the project. Defaults to the current working directory's basename.

### `MAKESTER__SERVICE_NAME`
A service identifier that defaults to `MAKESTER__PROJECT_NAME`. This can be used to target your container
repository and identify your image.

`MAKESTER__SERVICE_NAME` can be overridden at the top of your `Makefile` as follows:
``` sh
# Include overrides (must occur before include statements).
MAKESTER__SERVICE_NAME := supa-cool-service-name
```

!!! note
    If `MAKESTER__REPO_NAME` is defined in your `Makefile` then `MAKESTER__SERVICE_NAME` becomes
    `MAKESTER__REPO_NAME/MAKESTER__PROJECT_NAME`. For example `supa-cool-repo/my-project` is achieved with the following:
    ``` sh
    MAKESTER__REPO_NAME := supa-cool-repo
    MAKESTER__PROJECT_NAME := my-project
    ```

### `MAKESTER__STATIC_SERVICE_NAME`
Same as [MAKESTER__SERVICE_NAME](#makester__service_name) but guaranteed not to change. With the
introduction of the [local registry server](../docker/#deploy-a-local-registry-server),
`MAKESTER__SERVICE_NAME` could be altered to incorporate the name of the local registry server.

!!! note
    `MAKESTER__STATIC_SERVICE_NAME` is the static equivalent of the initialised
    `MAKESTER__SERVICE_NAME` and cannot be overridden.

### `HASH`
As per `git rev-parse --help`. The `HASH` value of your `git` branch allows you to uniquely
identify each build revision within your project. Once you merge your code changes back into
the `main` branch, you can `make image-tag-latest` to tag the image with `latest`.

### `MAKESTER__VERSION`
Manually managed versioning control (defaults to `0.0.0`).

### `MAKESTER__RELEASE_NUMBER`
Manually managed release number control when `MAKESTER__VERSION` is unchanged (defaults to `1`).

### `MAKESTER__RELEASE_VERSION`
Advanced versioning control that provides a hook into an autonomous versioning facility
(for example, [GitVersion](https://gitversion.net/docs/)).

### `MAKESTER__LOCAL_IP`
Platform independent way to get the local host's IP address.

### `MAKESTER__WORK_DIR`
Working area that Makester uses to store information (defaults to `$PWD/.makester`).

!!! note
    Be sure to add the location of `MAKESTER__WORK_DIR` into your project's `.gitignore`.

### `MAKESTER__K8S_MANIFESTS`
Location of your project's Kubernetes manifests (defaults to `<MAKESTER__WORK_DIR>/k8s/manifests`).

### `MAKESTER__PROJECT_DIR`
The home directory of the project (defaults to `$PWD` or the top level of where your
project's `.git` directory can be found).

### `MAKESTER__PACKAGE_NAME`
The name to use for the package distribution. Defaults to the `MAKESTER__PROJECT_NAME`
but available if a distinction is required. `MAKESTER__PACKAGE_NAME` is also used to
build the `MAKESTER__PYTHON_PROJECT_ROOT`  directory.

### `MAKESTER__INCLUDES`
!!! tag "[Makester v0.2.3](https://github.com/loum/makester/releases/tag/0.2.3)"
Control the Makester includes (defaults to all Makester `Makefile`s `py docker compose k8s kompose
versioning docs`).

---
[top](#makester)
