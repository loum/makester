# Versioning

Makester versioning provide two separate streams:

- **Static:**
    - You manually control version increments in your `Makefile`. Makester versioning provides the variables `MAKESTER__VERSION` and `MAKESTER__RELEASE_NUMBER` for static version management.
- **Dynamic:**
    - Leverages [https://gitversion.net/](https://gitversion.net/).

Either way, Makester versioning will pre-populate the `MAKESTER__RELEASE_VERSION` variable that
you can use throughout your project. 

!!! note
    Dynamic versioning takes precedence over static. Makester versioning will first check if dynamic
    versioning output has been generated. The static version value will only be used as a fallback
    if the dynamic versioning value is not found.

For dynamic versioning, GitVersion's defaults may be all that your project needs. But code versioning can be a touchy subject. Customising your own `GitVersion.yml` will give you full control over this facility. Follow the [GitVersion configuration guide](https://gitversion.net/docs/reference/configuration) to initialise your own `GitVersion.yml`. Makester also provides a [working, sample `GitVersion.yml`](https://github.com/loum/makester/blob/main/sample/GitVersion.yml) that is geared towards Python projects.

The Makester versioning subsystem help lists the available commands:
```
make versioning-help
```

## Command Reference

### Display the GitVersion Usage Message
```
make gitversion
```

### Generate Dynamic Version
!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4)"
    The `gitversion-release` target was renamed `gitversion-release`  from `makefiles/python-venv.mk`
    in [Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4). `gitversion-release`
    will be deprecated in [Makester v0.3.0](https://github.com/loum/makester/releases/tag/0.3.0)

The output is filtered against the GitVersion variable defined by `MAKESTER__GITVERSION_VARIABLE`
(defaults to `AssemblySemFileVer`). For example:
```
### Filtering GitVersion variable: AssemblySemFileVer
### MAKESTER__RELEASE_VERSION: "0.1.0.0"
```

`gitversion-release` creates static output files under Makester's `MAKESTER__WORK_DIR`. These are namely:

- `<MAKESTER__WORK_DIR>/versioning`
    - The complete GitVersion variable output in JSON format.
- `<MAKESTER__WORK_DIR>/VERSION`
    - The filtered version that can be sourced throughout your project.

If version currency is important for a particular function, then you can chain the `gitversion-release` target to other targets within your `Makefile`. For example, when you are building a fresh Docker image, the following recipe will ensure that a new `MAKESTER__RELEASE_NUMBER` is generated just prior to the Docker image build process:
```
image-build: gitversion-release
```

Makester versioning uses its own `GitVersion.yml` by default. However, you can specify your own by placing it at the top level of your project repository and setting `MAKESTER__GITVERSION_CONFIG` in your `Makefile`.

### Dynamic Version Dump
A read-only variant of `gitversion-release` that will not clobber version content in `MAKESTER__VERSION_FILE`.
```
make gitversion-release-ro
```

### Clear the Dynamic GitVersion Output 
```
make gitversion-clear
```
All files under `MAKESTER__WORK_DIR` are removed.

## Variables
### `MAKESTER__VERSION_FILE`
Configurable, static file reference to write the output of `gitversion-release` target (defaults to `$PWD/.makester/VERSION`).

### `MAKESTER__GITVERSION_CONFIG`
Optionally specify the location of your project's `GitVersion.yml` (defaults to Makester's default `sample/GitVersion.yml`.

### `MAKESTER__GITVERSION_VARIABLE`
GitVersion release variable value filter (defaults to `AssemblySemFileVer`).

### `MAKESTER__GITVERSION_VERSION`
GitVersion docker image version (defaults to `latest`).
