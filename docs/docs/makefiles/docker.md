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

``` sh title="Hello World image container runtime output."
/usr/bin/docker build -t supa-cool-repo/my-project:99296c8 sample
Sending build context to Docker daemon  3.072kB
Step 1/1 : FROM hello-world
 ---> d1165f221234
Successfully built d1165f221234
Successfully tagged supa-cool-repo/my-project:99296c8
```

The resultant image build can be viewed:
``` sh
make -f sample/Makefile image-search
```

``` sh title="Image in docker."
REPOSITORY                  TAG       IMAGE ID       CREATED         SIZE
supa-cool-repo/my-project   52c13b1   281099761321   10 months ago   9.14kB
```

To run your new `supa-cool-repo/my-project:99296c8` container:
``` sh
make -f sample/Makefile container-run
```

Makester also supports image builds with
[BuildKit](https://docs.docker.com/build/buildkit/){target="_blank"}.

``` sh
make -f sample/Makefile image-buildx
```

``` sh title="Hello World image build with BuildKit."
[+] Building 0.7s (6/6) FINISHED
 => [internal] load build definition from Dockerfile                                       0.0s
 => => transferring dockerfile: 54B                                                        0.0s
 => [internal] load .dockerignore                                                          0.0s
 => => transferring context: 2B                                                            0.0s
 => [internal] load metadata for docker.io/library/hello-world:latest                      0.6s
 => CACHED [1/1] FROM docker.io/library/hello-world@sha256:aa0cc8055b82dc2509bed2e19b275c  0.0s
 => => resolve docker.io/library/hello-world@sha256:aa0cc8055b82dc2509bed2e19b275c8f46350  0.0s
 => exporting to oci image format                                                          0.1s
 => => exporting layers                                                                    0.0s
 => => exporting manifest sha256:09fa5bdba956b1732511e681f392cabd75554ffbc85e9ea2c7ee4925  0.0s
 => => exporting config sha256:52cac4254827711f6b1c1c75c516538b7b95656723f8aa6a4f74a9a59b  0.0s
 => => sending tarball                                                                     0.1s
 => importing to docker                                                                    0.0s
```

Makester performs a couple of customisations for you behind the scenes to steamline the image build process
with BuildKit. These include:

- Identifies your platform and uses that value to set the `--platform` to `docker buildx build`.
- Adds the `--load` switch to `docker buildx build` so that the new image is exported into docker.

!!! warning
    Without the `--load` switch, the `docker buildx build` process will display the following
    warning:
    ``` sh
    WARNING: No output specified with docker-container driver. Build result will only remain in the build cache. To push result image into registry use --push or to load image into docker use --load
    ```

To see the new plan for `docker buildx build`:
``` sh
make -n -f sample/Makefile image-buildx
```

``` sh title="BuildKit's docker buildx build plan."
docker buildx build --platform linux/arm64 --load -t supa-cool-repo/my-project:52c13b1 sample
```

### Support for multi-architecture builds
!!! tag "[Makester v0.2.2](https://github.com/loum/makester/releases/tag/0.2.2){target="_blank"}"

Makester can now [Leverage multi-CPU architecture support](https://docs.docker.com.xy2401.com/docker-for-mac/multi-arch/){target="_blank"}. However, there are some manual steps that need to be performed.

### Define your target Docker platforms
To build an image that supports multiple architectures, you can define these by setting the
`MAKESTER__DOCKER_PLATFORM` Makester variable. For example:

``` sh
MAKESTER__DOCKER_PLATFORM=linux/arm64,linux/amd64 make -f sample/Makefile image-buildx
```

However, in the default docker image build system you may see this error:

``` sh
ERROR: docker exporter does not currently support exporting manifest lists
```

To mitigate this error, we will need to create new `buildx` builder. In this example, we will
call the new builder `multiarch`. Change this name to suit your requirements::

``` sh
docker buildx create --driver-opt network=host --name multiarch --use
```

Check to ensure that the new `multiarch` builder has been selected for use (note `multiarch *`):

``` sh title="List available BuildKit builders."
docker buildx ls
```

``` sh title="New BuildKit builder is selected."
NAME/NODE        DRIVER/ENDPOINT             STATUS   BUILDKIT PLATFORMS
multiarch *      docker-container
  multiarch0     unix:///var/run/docker.sock running  v0.11.1  linux/arm64, linux/amd64, linux/amd64/v2, linux/riscv64, linux/ppc64le, linux/s390x, linux/386, linux/mips64le, linux/mips64, linux/arm/v7, linux/arm/v6
```

Recall that Makester's `docker buildx build` attempts to load the new image into docker's
registry. However, this is not possible with BuildKit as it runs as a completely different
process. Instead, we can load into a local registry server. Create the server as follows:

``` sh
make image-registry-start
```

The image tag will also be updated to reflect the local registry server:

``` sh
MAKESTER__DOCKER_PLATFORM=linux/arm64,linux/amd64 make -n -f sample/Makefile image-buildx
```

``` sh title="BuildKit build plan with the local registry server running."
docker buildx build --platform linux/arm64,linux/amd64 --push -t localhost:15000/supa-cool-repo/my-project:52c13b1 sample
```

!!! warning
    Makester will make subtle changes to your Docker build command based on whether the local
    registry server is running or not. If you experience unexpected behaviour, check the status of
    your server.

Now we can build the multi-platform container image:

``` sh
MAKESTER__DOCKER_PLATFORM=linux/arm64,linux/amd64 make -f sample/Makefile image-buildx
```

To see the images in your local registry server, first list the catalog:
``` sh
curl -X GET http://localhost:15000/v2/_catalog
```

``` sh title="Local registry server catalog"
{"repositories":["supa-cool-repo/my-project"]}
```

Next, get the list of available tags:
``` sh
curl -X GET http://localhost:15000/v2/supa-cool-repo/my-project/tags/list
```

``` sh title="Available tags"
{"name":"supa-cool-repo/my-project","tags":["52c13b1"]}
```

To access the new image from the local registry server:
``` sh
docker pull localhost:15000/supa-cool-repo/my-project:52c13b1
```

Create a tag to align with the project's naming convention:
``` sh
docker tag localhost:15000/supa-cool-repo/my-project:52c13b1 supa-cool-repo/my-project:52c13b1
```

Now it is possible to search for the new, multi-platform image as per normal:
``` sh
make -f sample/Makefile image-search
```

``` sh title="Image search for new, multi-platform image in docker output."
REPOSITORY                  TAG       IMAGE ID       CREATED         SIZE
supa-cool-repo/my-project   52c13b1   52cac4254827   10 months ago   9.14kB
```

Not convinced that the new images have been built with multi-platform support?:
``` sh title="Inspect image architectures."
docker buildx imagetools inspect localhost:15000/supa-cool-repo/my-project:52c13b
```

``` sh title="Image inspect output."
Name:      localhost:15000/supa-cool-repo/my-project:52c13b1
MediaType: application/vnd.oci.image.index.v1+json
Digest:    sha256:6a8497a3199b5a220c175ae8c3d0b11149f04b5191e94fcce49b16bdfd630e98

Manifests:
  Name:        localhost:15000/supa-cool-repo/my-project:52c13b1@sha256:73752638c848a53e033f1a7db6a1f2459e41cd291edbd4f6356593f915b2da63
  MediaType:   application/vnd.oci.image.manifest.v1+json
  Platform:    linux/arm64

  Name:        localhost:15000/supa-cool-repo/my-project:52c13b1@sha256:86954c5e397fdde46080e1bf13568bce1def33267125d6cbb9220eb0fd0a55f1
  MediaType:   application/vnd.oci.image.manifest.v1+json
  Platform:    linux/amd64
```

### Image clean up
To delete the `supa-cool-repo/my-project` image:
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

The registry can be accessed with `curl`:
``` sh
curl -X GET http://localhost:15000/v2/supa-cool-repo/my-project/tags/list
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

Version defaults to `0.0.0-1` but this can be overridden by setting `MAKESTER__VERSION` and
`MAKESTER__RELEASE_NUMBER` in your `Makefile`. Alternatively, to align with your preferred tagging
convention, override the `MAKESTER__IMAGE_TAG` parameter. For example:
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

### `MAKESTER__IMAGE_TARGET_TAG`
Unique identifier used to distinguish container image builds. Defaults to
[HASH](../makester/#hash).

### `MAKESTER__IMAGE_TAG_ALIAS`
Convenience variable that is made up of the 
[Hello](../makester/#makester__service_name) and `MAKESTER__IMAGE_TARGET_TAG`. For example:

``` sh title="MAKESTER__SERVICE_NAME sample value"
MAKESTER__SERVICE_NAME=supa-cool-repo/my-project
```

``` sh title="MAKESTER__SERVICE_NAME sample value"
MAKESTER__IMAGE_TARGET_TAG=52c13b1
```

``` sh
make -f sample/Makefile print-MAKESTER__IMAGE_TAG_ALIAS
```

``` sh title="MAKESTER__IMAGE_TAG_ALIAS based on MAKESTER__SERVICE_NAME:MAKESTER__IMAGE_TAG_ALIAS"
MAKESTER__IMAGE_TAG_ALIAS=supa-cool-repo/my-project:52c13b1
```

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

### `MAKESTER__DOCKER_PLATFORM`
Override the `--platform` switch to `docker buildx`.
[Multi-architecture builds](#support-for-multi-architecture-builds) are supported.

### `MAKESTER__LOCAL_REGISTRY`
The host and IP of the local Docker image registry server.

Makester provides a default value based on your system's IP address and the port `15000`. For
example, `192.168.1.211:15000`. These values can be overridden by providing values for
`MAKESTER__LOCAL_IP` and `MAKESTER__LOCAL_REGISTRY_IP`. Or, `MAKESTER__LOCAL_REGISTRY` can be
overridden directly. For example:

``` sh
MAKESTER__LOCAL_REGISTRY=localhost:5001 make print-MAKESTER__LOCAL_REGISTRY
```

``` sh title="Overriding MAKESTER__LOCAL_REGISTRY."
MAKESTER__LOCAL_REGISTRY=localhost:5001
```
