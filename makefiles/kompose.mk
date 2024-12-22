ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := kompose-help
endif

ifndef MAKESTER__PRIMED
$(info ### Add the following include statement to your Makefile)
$(info include makester/makefiles/makester.mk)
$(error ### missing include dependency)
endif

# Defaults that can be overridden.
MAKESTER__KOMPOSE_EXE_NAME ?= kompose
MAKESTER__KOMPOSE_EXE_INSTALL ?= https://kompose.io/installation/

MAKESTER__KOMPOSE := $(call check-exe,$(MAKESTER__KOMPOSE_EXE_NAME),$(MAKESTER__KOMPOSE_EXE_INSTALL),optional)

_kompose-cmd:
	$(if $(MAKESTER__KOMPOSE),,$(call _kompose-cmd-err))
	$(MAKESTER__KOMPOSE) $(KOMPOSE_CMD) || true

define _kompose-cmd-err
	$(info ### MAKESTER__KOMPOSE: <undefined>)
	$(info ### MAKESTER__KOMPOSE_EXE_NAME set as "$(MAKESTER__KOMPOSE_EXE_NAME)")
	$(call check-exe,$(MAKESTER__KOMPOSE_EXE_NAME),$(MAKESTER__KOMPOSE_EXE_INSTALL))
endef

MAKESTER__COMPOSE_K8S_EPHEMERAL ?= docker-compose.yml
kompose: MAKESTER__K8S_MANIFESTS := $(MAKESTER__K8S_MANIFESTS)
kompose: KOMPOSE_CMD = convert --file $(MAKESTER__COMPOSE_K8S_EPHEMERAL) --out $(MAKESTER__K8S_MANIFESTS)
kompose: makester-work-dir makester-k8s-manifest-dir _kompose-cmd

_kompose-rm: MAKESTER__WORK_DIR := $(MAKESTER__WORK_DIR)
_kompose-rm:
	-@$(info ### removing $(MAKESTER__K8S_MANIFESTS)/*.y?ml)
	$(shell rm -r $(MAKESTER__K8S_MANIFESTS)/*.y?ml)

kompose-clear: _kompose-rm

kompose-help:
	printf "\n($(MAKESTER__MAKEFILES)/kompose.mk)\n"
	$(call help-line,kompose,Convert config files from \"$(MAKESTER__COMPOSE_K8S_EPHEMERAL)\")

.PHONY: kompose-help
