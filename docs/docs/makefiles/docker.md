# Docker

Docker is core to [Makester](https://github.com/loum/makester.git) for both container image
management and integrating supporting containerised services. For example,
[GitVersion](https://hub.docker.com/r/gittools/gitversion). Wrap your wieldy, common [Docker
commands](https://docs.docker.com/engine/reference/commandline/cli/)  into a `make` target and start being productive.

The Makester Docker subsystem help lists the available commands:
```
make docker-help
```

## Example
A [sample Dockerfile](https://github.com/loum/makester/blob/main/sample/Dockerfile) is provided by [Makester](https://github.com/loum/makester.git) to demonstrate basic capability.

!!! note
    If you are running the following commands from Makester which has been setup within your
    project repository, then replace `sample/Makefile` with `makester/sample/Makefile`.

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
make -f sample/Makefile image-rm
```

## Command Reference
### Build your Docker Image
```
make image-build
```
Alternatively, leverage the features provided by [BuildKit](https://docs.docker.com/build/buildkit/):
```
make image-buildx
```
### Run your Docker Images as a Container
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
### Tag Docker mage with a Custom Versioning Policy
```
make tag-version
```
Version defaults to `0.0.0-1` but this can be overridden by setting `MAKESTER__VERSION` and `MAKESTER__RELEASE_NUMBER` in your `Makefile`. Alternatively, to align with your preferred tagging convention, override the `MAKESTER__IMAGE_TAG` parameter. For example:
```
make tag MAKESTER__IMAGE_TAG=supa-tag-01
```
### Remove your Docker Image
```
make image-rm
```
### Remove Dangling Docker Images
```
make rm-dangling-images
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
```
MAKESTER__BUILD_COMMAND := -t $(MAKESTER__SERVICE_NAME):$(HASH) .
```
