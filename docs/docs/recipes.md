# Recipes

## Integrate `makester backoff` with `docker compose`

The following recipe defines a _backoff_ strategy with `docker compose` in addition
to adding an action to run the initialisation script, `init-script.sh`:
```
backoff:
    @makester backoff localhost 10000 --detail "HiveServer2"
    @makester backoff localhost 10002 --detail "Web UI for HiveServer2"

local-build-up: compose-up backoff
    @./init-script.sh
```

## Provide Multiple `docker-compose` `up`/`down` Targets

Override `MAKESTER__COMPOSE_FILES` Makester parameter to customise multiple build/destroy environments:
```
test-compose-up: MAKESTER__COMPOSE_FILES = -f docker-compose.yml -f docker-compose-test.yml
test-compose-up: compose-up

dev-compose-up: MAKESTER__COMPOSE_FILES = -f docker-compose.yml -f docker-compose-dev.yml
dev-compose-up: compose-up
```

!!! note
    Remember to provide the complimentary `docker-compose` `down` targets in your `Makefile`.
