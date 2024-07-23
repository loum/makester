# Docker Compose

Traditional Makester compose has supported
[docker compose](https://docs.docker.com/engine/reference/commandline/compose/) capability for basic
multi-container orchestration. Makester strategy is to move more into the Kubernetes space. As such, support
for Makester compose will continue to diminish over time.

!!! note
    Support for PyPI `docker-compose` has been deprecated as there does not appear to be a roadmap
    within that project to move to [docker compose V2](https://docs.docker.com/compose/compose-v2/).

As of [Moby 20.10.13](https://github.com/moby/moby/releases/tag/v20.10.13), [docker compose V2](https://docs.docker.com/compose/compose-v2/) is integrated into the Docker CLI. This means that we do not need to support the installation of the standalone [docker-compose](https://docs.docker.com/compose/install/other/).

The Makester Docker compose subsystem help lists the available commands:

```
make compose-help
```

## Command Reference

### Build your Compose Stack

```
make compose-up
```

#### Example

A [sample docker-compose.yml](https://github.com/loum/makester/blob/main/sample/docker-compose.yml)
is provided for testing. The sample stack can be created with the following command:

```
SAMPLE_COMPOSE_PORT=19999 MAKESTER__COMPOSE_FILES="-f sample/docker-compose.yml" make compose-up
```

Then navigate to [http://localhost:19999](http://localhost:19999) in your browser to see a simple NGiNX test page.

Run `make compose-down` to bring the stack down.

### Destroy your Compose Stack

```
make compose-down
```

### Dump your Compose Stack's Configuration

```
make compose-config
```

## Variables

### `MAKESTER__COMPOSE_FILES`

Makester compose expects a `docker-compose.yml` in the top level directory of the project repository. However, this can overridden by setting the `MAKESTER__COMPOSE_FILES` parameter:

```
MAKESTER__COMPOSE_FILES = -f docker-compose-supa.yml
```

### `MAKESTER__COMPOSE_RUN_CMD`

If you need more control over `docker compose`, then override the `MAKESTER__COMPOSE_RUN_CMD` parameter in your `Makefile`. For example, to specify the verbose output option:

```
MAKESTER__COMPOSE_RUN_CMD ?= SERVICE_NAME=$(MAKESTER__PROJECT_NAME) HASH=$(HASH)\
 $(MAKESTER__DOCKER_COMPOSE)\
 --verbose\
 $(MAKESTER__COMPOSE_FILES) $(COMPOSE_CMD)
```

### `MAKESTER__COMPOSE_FILES`

Override the `docker compose` `--file` switch (defaults to `-f docker-compose.yml`).

### `MAKESTER__COMPOSE_RUN_CMD`

Override the `docker compose` run command.

______________________________________________________________________

[top](#docker-compose)
