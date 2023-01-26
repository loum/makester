# Docker

Docker is core to [Makester](https://github.com/loum/makester.git){target="_blank"} for both container image
management and integrating supporting containerised services. For example,
[GitVersion](https://hub.docker.com/r/gittools/gitversion){target="_blank"}. Wrap your wieldy, common [Docker
commands](https://docs.docker.com/engine/reference/commandline/cli/){target="_blank"} into a `make` target
and start being productive.

The Makester Docker subsystem help lists the available commands:
``` sh
make docker-help
```

## Example
A [sample Dockerfile](https://github.com/loum/makester/blob/main/sample/Dockerfile){target="_blank"}
is provided by [Makester](https://github.com/loum/makester.git){target="_blank"} to demonstrate basic capability.

!!! note
    If you are running the following commands from Makester which has been setup within your
    project repository, then replace `sample/Makefile` with `makester/sample/Makefile`.

To get help at any time:
``` sh
make -f sample/Makefile help
```

Build a Docker image based off the "Hello World" image:
``` sh
make -f sample/Makefile image-build
```

``` sh title="Hello World image container runtime output.""
/usr/bin/docker build -t supa-cool-repo/my-project:99296c8 sample
Sending build context to Docker daemon  3.072kB
Step 1/1 : FROM hello-world
 ---> d1165f221234
Successfully built d1165f221234
Successfully tagged supa-cool-repo/my-project:99296c8
```

To run your new `supa-cool-repo/my-project:99296c8` container:
``` sh
make -f sample/Makefile run
```

To delete the `supa-cool-repo/my-project:99296c8` image:
``` sh
make -f sample/Makefile image-rm
```

## Command reference

### Deploy a local registry server
!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4){target="_blank"}"

As per notes on how to [Deploy a registry server](https://docs.docker.com/registry/deploying/){target="_blank"}.
``` sh
make image-registry-start
```

To stop the local image registry server:
``` sh
make image-registry-stop
```

### Build your Docker image
``` sh
make image-build
```

Alternatively, leverage the features provided by
[BuildKit](https://docs.docker.com/build/buildkit/){target="_blank"}:
``` sh
make image-buildx
```

### Run your Docker images as a container
``` sh
make container-run
```

The `container-run` target can be controlled in your `Makefile` by overriding the
`MAKESTER__RUN_COMMAND` parameter. For example:
``` sh
MAKESTER__RUN_COMMAND := $(MAKESTER__DOCKER) run --rm -d --name $(MAKESTER__CONTAINER_NAME) $(MAKESTER__SERVICE_NAME):$(HASH)
```

### Tag Docker image with the `latest` tag
``` sh
make image-tag
```

### Tag Docker image with a custom versioning policy
``` sh
make image-tag-version
```

Version defaults to `0.0.0-1` but this can be overridden by setting `MAKESTER__VERSION` and `MAKESTER__RELEASE_NUMBER` in your `Makefile`. Alternatively, to align with your preferred tagging convention, override the `MAKESTER__IMAGE_TAG` parameter. For example:
``` sh
make tag MAKESTER__IMAGE_TAG=supa-tag-01
```

### Remove your Docker image
``` sh
make image-rm
```

### Remove dangling Docker images
``` sh
make image-rm-dangling
```

## Variables

### `MAKESTER__CONTAINER_NAME`
Control the name of your image container (defaults to `my-container`).

### `MAKESTER__IMAGE_TAG`
Defaults to `latest`.

### `MAKESTER__RUN_COMMAND`
Override the image container run command that is initiated by `make container-run`.

### `MAKESTER__BUILD_COMMAND`
Override the command line options to `docker build` or `docker buildx build` to have more fine-grained control over the container image build process. For example, the following snippet overrides the image tag:
``` sh
MAKESTER__BUILD_COMMAND := -t $(MAKESTER__SERVICE_NAME):$(HASH) .
```
