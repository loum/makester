ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := kompose-help
endif

ifndef MAKESTER__PRIMED
$(info ### Add the following include statement to your Makefile)
$(info include makester/makefiles/makester.mk)
$(error ### missing include dependency)
endif

# Kompose is needed.
MAKESTER__KOMPOSE ?= $(call check-exe,kompose,https://kompose.io/installation/)

_kompose-cmd:
	$(MAKESTER__KOMPOSE) $(KOMPOSE_CMD) || true

MAKESTER__COMPOSE_K8S_EPHEMERAL ?= docker-compose.yml
kompose: MAKESTER__K8S_MANIFESTS := $(MAKESTER__K8S_MANIFESTS)
kompose: KOMPOSE_CMD = convert --file $(MAKESTER__COMPOSE_K8S_EPHEMERAL) --out $(MAKESTER__K8S_MANIFESTS)
kompose: makester-work-dir makester-k8s-manifest-dir _kompose-cmd

_kompose-rm: MAKESTER__WORK_DIR := $(MAKESTER__WORK_DIR)
_kompose-rm:
	-@$(info ### removing $(MAKESTER__K8S_MANIFESTS)/*.y?ml $(shell rm -r $(MAKESTER__K8S_MANIFESTS)/*.y?ml))

kompose-clear: _kompose-rm

kompose-help:
	@echo "(makefiles/kompose.mk)\n\
  kompose              Convert config files from \"$(MAKESTER__COMPOSE_K8S_EPHEMERAL)\"\n"

.PHONY: kompose-help
