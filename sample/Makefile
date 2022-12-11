MAKESTER__REPO_NAME := supa-cool-repo
MAKESTER__PROJECT_NAME := my-project
MAKESTER__CONTAINER_NAME := mega-container

include makefiles/makester.mk
include makefiles/docker.mk
include makefiles/py.mk

MAKESTER__BUILD_COMMAND = -t $(MAKESTER__SERVICE_NAME):$(HASH) sample

init: py-venv-clear py-venv-init py-install

help: makester-help docker-help py-help
	@echo "(simple/Makefile)\n\
  init                 Build Makester environment\n"
