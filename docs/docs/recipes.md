# Recipes

!!! warning
    Don't forget to indent your `Makefile` targets with the `<tab>` character.

## Utilities

### Integrate `makester backoff` with `docker compose`

The following recipe defines a _backoff_ strategy with `docker compose` in addition
to adding an action to run the initialisation script, `init-script.sh`:

```sh
backoff:
    @makester backoff localhost 10000 --detail "HiveServer2"
    @makester backoff localhost 10002 --detail "Web UI for HiveServer2"

local-build-up: compose-up backoff
    @./init-script.sh
```

## Docker

### Multi-arch builds

As you may have noticed, [multi-architecture builds](makefiles/docker.md#support-for-multi-architecture-builds)
can be somewhat of a grind. This recipe creates a new target called `multi-arch-build` that will:

- creates a new `buildx builder` called `multiarch` and selects that for use
- starts the local image registry
- builds image with multi-architecture support and publishes to the local registry server
- shifts the new multi-architecture image from the local registry server into docker

```sh title="Multi-arch container image builds."
image-pull-into-docker:
    $(info ### Pulling local registry image $(MAKESTER__SERVICE_NAME):$(HASH) into docker)
    $(MAKESTER__DOCKER) pull $(MAKESTER__SERVICE_NAME):$(HASH)

image-tag-in-docker: image-pull-into-docker
    $(info ### Tagging local registry image $(MAKESTER__SERVICE_NAME):$(HASH) for docker)
    $(MAKESTER__DOCKER) tag $(MAKESTER__SERVICE_NAME):$(HASH) $(MAKESTER__STATIC_SERVICE_NAME):$(HASH)

image-transfer: image-tag-in-docker
    $(info ### Deleting pulled local registry image $(MAKESTER__SERVICE_NAME):$(HASH))
    $(MAKESTER__DOCKER) rmi $(MAKESTER__SERVICE_NAME):$(HASH)

multi-arch-build: image-registry-start image-buildx-builder
    $(info ### Starting multi-arch builds ...)
    $(MAKE) MAKESTER__DOCKER_PLATFORM=linux/arm64,linux/amd64 image-buildx
    $(MAKE) image-transfer
    $(MAKE) image-registry-stop
```

## Docker compose

### Provide Multiple `docker compose` `up`/`down` Targets

Override `MAKESTER__COMPOSE_FILES` Makester parameter to customise multiple build/destroy environments:

```sh
test-compose-up: MAKESTER__COMPOSE_FILES = -f docker-compose.yml -f docker-compose-test.yml
test-compose-up: compose-up

dev-compose-up: MAKESTER__COMPOSE_FILES = -f docker-compose.yml -f docker-compose-dev.yml
dev-compose-up: compose-up
```

!!! note
    Remember to provide the complimentary `docker compose` `down` targets in your `Makefile`.

## Versioning

### Release branch and tagging

!!! tag "[Makester v0.2.3](https://github.com/loum/makester/releases/tag/0.2.3){target="\_blank"}"

The [sample GitVersion.yml](https://github.com/loum/makester/blob/main/sample/GitVersion.yml){target="\_blank"}
now includes a dedicated `release` section that caters for `release` branches. This allows you to
version increment main-line releases independent from your main-line branch. This mitigates the need to make
changes directly to your `main` branch. For example:

```sh title="Preparing for release."
git checkout main
git checkout -b release
make gitversion-release
```

The `gitversion release` will update your `VERSION` file in accordance with your main-line version
incremental rules.

Here is a sample GitHub action that creates a tag and pre-release when the `VERSION` file change
has been detected. It is based on `makester`'s versioning strategy and the excellent
[marvinpinto/action-automatic-releases](https://github.com/marvinpinto/action-automatic-releases){target="\_blank"}
action:

```sh title="VERSION file action for automatic releases"
name: Makester CI
run-name: ${{ github.actor }} ${{ github.event_name }} event Makester CI 🚀
on: push
permissions:
  contents: write

jobs:
  pre-release:
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository code
        uses: actions/checkout@v3
        with:
          submodules: recursive
          fetch-depth: 0
      - name: Check if the VERSION file has changed
        id: changed_version_file
        uses: tj-actions/changed-files@v35
        with:
          files: src/makester/VERSION
      - name: Read VERSION file
        if: steps.changed_version_file.outputs.any_changed == 'true'
        id: get_version
        run: echo "VERSION=$(cat src/makester/VERSION)" >> $GITHUB_OUTPUT
      - name: Create pre-release
        if: steps.changed_version_file.outputs.any_changed == 'true'
        uses: "marvinpinto/action-automatic-releases@latest"
        with:
          repo_token: "${{ secrets.GITHUB_TOKEN }}"
          title: ${{ steps.get_version.outputs.version }}
          automatic_release_tag: ${{ steps.get_version.outputs.VERSION }}
          prerelease: true
```

______________________________________________________________________

[top](#recipes)
