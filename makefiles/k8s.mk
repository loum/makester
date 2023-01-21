ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := k8s-help
endif

ifndef MAKESTER__PRIMED
$(info ### Add the following include statement to your Makefile)
$(info include makester/makefiles/makester.mk)
$(error ### missing include dependency)
endif

# Defaults that can be overridden.
MAKESTER__MINIKUBE_EXE_NAME ?= minikube
MAKESTER__MINIKUBE_EXE_INSTALL ?= https://kubernetes.io/docs/tasks/tools/\#minikube
MAKESTER__KUBECTL_EXE_NAME ?= kubectl
MAKESTER__KUBECTL_EXE_INSTALL ?= https://kubernetes.io/docs/tasks/tools/

MAKESTER__MINIKUBE := $(call check-exe,$(MAKESTER__MINIKUBE_EXE_NAME),$(MAKESTER__MINIKUBE_EXE_INSTALL),optional)
MAKESTER__KUBECTL := $(call check-exe,$(MAKESTER__KUBECTL_EXE_NAME),$(MAKESTER__KUBECTL_EXE_INSTALL),optional)

minikube-cmd:
	$(if $(MAKESTER__MINIKUBE),,$(call _minikube-cmd-err))
	$(MAKESTER__MINIKUBE) $(MK_CMD) || true

define _minikube-cmd-err
	$(info ### MAKESTER__MINIKUBE: <undefined>)
	$(info ### MAKESTER__MINIKUBE_EXE_NAME set as "$(MAKESTER__MINIKUBE_EXE_NAME)")
	$(call check-exe,$(MAKESTER__MINIKUBE_EXE_NAME),$(MAKESTER__MINIKUBE_EXE_INSTALL))
endef

ifdef MAKESTER__MINIKUBE
.makester/mk-docker-env.mk: Makefile
	-@$(shell which mkdir) -p .makester
	@$(MAKESTER__MINIKUBE) docker-env | grep '=' | cut -d' ' -f 2 > $@
endif

-include .makester/mk-docker-env.mk
MK_DOCKER_ENV_VARS = $(shell sed -ne 's/ *\#.*$$//; /./ s/=.*$$// p' .makester/mk-docker-env.mk)

mk-docker-env-export:
	@$(foreach v,$(MK_DOCKER_ENV_VARS),$(eval $(shell echo export $(v)="$($(v))")))

mk-status: MK_CMD = status
mk-start: MK_CMD = start --driver docker
mk-start:
	$(shell sleep 5)
	$(MAKE) mk-docker-env-export
mk-dashboard: MK_CMD = dashboard
mk-stop: MK_CMD = stop
mk-del: MK_CMD = delete
mk-service: MK_CMD = service $(MAKESTER__PROJECT_NAME) --url
mk-status mk-start mk-dashboard mk-stop mk-del mk-service: minikube-cmd

kubectl-cmd:
	$(if $(MAKESTER__KUBECTL),,$(call _kubectl-cmd-err))
	-@$(MAKESTER__KUBECTL) $(KCTL_CMD) || true

define _kubectl-cmd-err
	$(info ### MAKESTER__KUBECTL: <undefined>)
	$(info ### MAKESTER__KUBECTL_EXE_NAME set as "$(MAKESTER__KUBECTL_EXE_NAME)")
	$(call check-exe,$(MAKESTER__KUBECTL_EXE_NAME),$(MAKESTER__KUBECTL_EXE_INSTALL))
endef

MAKESTER__K8_MANIFESTS := $(if $(MAKESTER__K8_MANIFESTS),$(MAKESTER__K8_MANIFESTS),./k8s/manifests)
MAKESTER__KUBECTL_CONTEXT := $(if $(MAKESTER__KUBECTL_CONTEXT),$(MAKESTER__KUBECTL_CONTEXT),minikube)

kube-context: KCTL_CMD = config get-contexts
kube-context-use: KCTL_CMD = config use-context $(MAKESTER__KUBECTL_CONTEXT)
kube-apply: KCTL_CMD = apply -f $(MAKESTER__K8_MANIFESTS)
kube-del: KCTL_CMD = delete -f $(MAKESTER__K8_MANIFESTS)
kube-get: KCTL_CMD = get pod,svc
kube-context kube-context-use kube-apply kube-del kube-get: kubectl-cmd
kube-apply kube-del: mkdir-k8s-manifests

k8s-help:
	@echo "($(MAKESTER__MAKEFILES)/k8s.mk)\n\
  kube-apply           Create resource(s) in all manifest files in \"${MAKESTER__K8_MANIFESTS}\" directory\n\
  kube-context         Get all Kubernetes cluster contexts\n\
  kube-context-set     Change Kubernetes cluster context by setting \"MAKESTER__KUBECTL_CONTEXT\" defaults \"minikube\"\n\
  kube-del             Delete a pod using the type and name specified in \"${MAKESTER__K8_MANIFESTS}\" directory\n\
  kube-get             View the Pods and Services\n\
  mk-dashboard         Access the Kubernetes Dashboard (Ctrl-C to stop)\n\
  mk-del               Delete Minikube local cluster\n\
  mk-service           Get Service access details (if \"LoadBalancer\" type specified)\n\
  mk-start             Start Minikube locally and create a cluster (docker driver)\n\
  mk-status            Check Minikube local cluster status\n\
  mk-stop              Stop Minikube local cluster\n"

.PHONY: k8s-help konvert .makester/mk-docker-env.mk
