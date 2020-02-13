# Dependencies:
#   - git
#   - docker
#
print-%:
	@echo '$*=$($*)'

clean:
	$(GIT) clean -xdf -e .vagrant -e *.swp -e 2env -e 3env

# Repo-wide globals (stuff you need to make everything work)
GIT := $(shell which git 2>/dev/null)
HASH := $(shell $(GIT) rev-parse --short HEAD)
DOCKER := $(shell which docker 2>/dev/null)
DOCKER_COMPOSE := $(shell which docker-compose 2>/dev/null || echo "3env/bin/docker-compose")

utils-help:
	@echo "\n\
Targets\n\
------------------------------------------------------------------------\n\
  (utils.mk)\n\
  print-<var>:      Display the Makefile global variable '<var>' value\n\
  clean:            Remove all files not tracked by Git\n\
	";

.PHONY: utils-help
