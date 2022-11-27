ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := k8s-help
endif

ifndef MAKESTER__PRIMED
$(info ### Add the following include statement to your Makefile)
$(info include makester/makefiles/makester.mk)
$(error ### missing include dependency)
endif

MINIKUBE := $(shell which minikube)
MAKESTER__KUBECTL ?= $(call check-exe,kubectl,https://kubernetes.io/docs/tasks/tools/)

minikube-cmd:
	$(MINIKUBE) $(MK_CMD) || true

.makester/mk-docker-env.mk: Makefile
	-@$(shell which mkdir) -p .makester
	@$(MINIKUBE) docker-env | grep '=' | cut -d' ' -f 2 > $@

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
	-@$(MAKESTER__KUBECTL) $(KCTL_CMD) || true

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
	@echo "(makefiles/k8s.mk)\n\
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
