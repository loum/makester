include makefiles/base.mk
include makefiles/docker.mk
include makefiles/python-venv.mk

bi: build-image

build-image:
	@$(DOCKER) build -t $(MAKESTER__SERVICE_NAME):$(HASH) sample 

rmi: rm-image

rm-image:
	@$(DOCKER) rmi $(MAKESTER__SERVICE_NAME):$(HASH) || true

help: base-help docker-help python-venv-help
	@echo "(simple/Makefile))\n\
  build-image:         Build docker image $(MAKESTER__SERVICE_NAME):$(HASH)\n\
  rm-image:            Delete docker image $(MAKESTER__SERVICE_NAME):$(HASH)\n\
	";

.PHONY: help
