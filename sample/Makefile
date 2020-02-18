include makefiles/base.mk
include makefiles/docker.mk
include makefiles/python-venv.mk

bi: build-image

build-image:
	@$(DOCKER) build -t $(MAKESTER__SERVICE_NAME):$(HASH) sample 

run:
	@$(DOCKER) run --rm \
      --name build-image \
      $(MAKESTER__SERVICE_NAME):$(HASH)

rmi: rm-image

rm-image:
	@$(DOCKER) rmi $(MAKESTER__SERVICE_NAME):$(HASH) || true

help: utils-help docker-help
	@echo "\n\
  (Makefile)\n\
  build-image:         Build docker image $(MAKESTER__SERVICE_NAME):$(HASH)\n\
  run:                 Run image $(MAKESTER__SERVICE_NAME):$(HASH)\n\
  rm-image:            Delete docker image $(MAKESTER__SERVICE_NAME):$(HASH)\n\
	";

.PHONY: help
