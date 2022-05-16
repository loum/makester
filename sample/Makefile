MAKESTER__REPO_NAME := supa-cool-repo
MAKESTER__PROJECT_NAME := my-project
MAKESTER__CONTAINER_NAME := mega-container

include makefiles/makester.mk
include makefiles/docker.mk
include makefiles/python-venv.mk
include makefiles/versioning.mk

MAKESTER__BUILD_COMMAND = $(DOCKER) build -t $(MAKESTER__SERVICE_NAME):$(HASH) sample

init: pip-requirements

help: makester-help docker-help python-venv-help
	@echo "(simple/Makefile)\n\
  init                 Build Makester environment\n"
