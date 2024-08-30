ifndef .DEFAULT_GOAL
  .DEFAULT_GOAL := microk8s-help
endif

ifndef MAKESTER__PRIMED
  $(info ### Add the following include statement to your Makefile)
  $(info include makester/makefiles/makester.mk)
  $(error ### missing include dependency)
endif

MAKESTER__MICROK8S_EXE_NAME ?= microk8s
MAKESTER__MICROK8S_EXE_INSTALL ?= https://microk8s.io/docs/getting-started
MAKESTER__MICROK8S ?= $(call check-exe,$(MAKESTER__MICROK8S_EXE_NAME),$(MAKESTER__MICROK8S_EXE_INSTALL),optional)

# MicroK8s command runner.
#
_uk8s-cmd:
	$(if $(MAKESTER__MICROK8S),,$(call _microk8s-cmd-err))
	-$(MAKESTER__MICROK8S) $(UK8S_CMD)

define _microk8s-cmd-err
	$(info ### MAKESTER__MICROK8S: <undefined>)
	$(info ### MAKESTER__MICROK8S_EXE_NAME set as "$(MAKESTER__MICROK8S_EXE_NAME)")
	$(call check-exe,$(MAKESTER__MICROK8S_EXE_NAME),$(MAKESTER__MICROK8S_EXE_INSTALL))
endef

# MicroK8s status.
#
_microk8s-status-msg:
	$(info ### Checking MicroK8s status ...)
microk8s-status: _microk8s-status-msg _microk8s-status
_microk8s-status: UK8S_CMD = status

# MicroK8s install.
ifndef MULTIPASS_CPU
  MULTIPASS_CPU := 2
endif
ifndef MULTIPASS_MEMORY
  MULTIPASS_MEMORY := 4
endif
ifndef MULTIPASS_DISK
  MULTIPASS_DISK := 50
endif
ifndef MULTIPASS_CHANNEL
  MULTIPASS_CHANNEL := 1.28/stable
endif
ifndef MULTIPASS_IMAGE
  MULTIPASS_IMAGE := 22.04
endif
_microk8s-install-msg:
	$(info ### Installing MicroK8s ...)
microk8s-install:
ifeq ($(MAKESTER__UNAME),Darwin)
	$(MAKE) _microk8s-install-msg _microk8s-install
endif
_microk8s-install: UK8S_CMD = install --cpu $(MULTIPASS_CPU) --mem $(MULTIPASS_MEMORY) --channel "$(MULTIPASS_CHANNEL)" --image $(MULTIPASS_IMAGE) --disk $(MULTIPASS_DISK)

# MicroK8s uninstall.
_microk8s-uninstall-msg:
	$(info ### Uninstalling MicroK8s ...)
microk8s-uninstall:
ifeq ($(MAKESTER__UNAME),Darwin)
	$(MAKE) _microk8s-uninstall-msg _microk8s-uninstall
endif
_microk8s-uninstall: UK8S_CMD = uninstall

# MicroK8s wait until running status.
#
microk8s-wait: _microk8s-status-msg _microk8s-wait
_microk8s-wait: UK8S_CMD = status --wait-ready

# Starts the kubernetes cluster and wait until running status.
#
_microk8s-start-msg:
	$(info ### Starting MicroK8s ...)
microk8s-start: _microk8s-start-msg _microk8s-start
_microk8s-start: UK8S_CMD = start
_microk8s-start:
	$(MAKE) microk8s-wait

# MicroK8s version.
#
microk8s-version: UK8S_CMD = version
microk8s-kubectl-version: UK8S_CMD = kubectl version --short

# Stops the kubernetes cluster.
#
_microk8s-stop-msg:
	$(info ### Stopping MicroK8s ...)
microk8s-stop: _microk8s-stop-msg _microk8s-stop
_microk8s-stop: UK8S_CMD = stop

# Cleans the cluster from all workloads.
#
_microk8s-reset-msg:
	$(info ### Resetting MicroK8s ...)
microk8s-reset:
ifeq ($(MAKESTER__UNAME),Darwin)
	$(MAKE) _microk8s-reset-msg _microk8s-reset
endif
_microk8s-reset: UK8S_CMD = reset

# MicroK8s enable the DNS addon.
#
_microk8s-addon-dns-msg:
	$(info ### Enabling the MicroK8s DNS addon ...)
microk8s-addon-dns: _microk8s-addon-dns-msg _microk8s-addon-dns microk8s-wait
_microk8s-addon-dns: UK8S_CMD = enable dns

# List the namespaces in the MicroK8s cluster.
#
# https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/
_microk8s-namespaces-msg:
	$(info ### Display all active namespaces in MicroK8s ...)
microk8s-namespaces: _microk8s-namespaces-msg _microk8s-namespaces
_microk8s-namespaces: UK8S_CMD = kubectl get namespace

# Add a namespace to the MicroK8s cluster.
#
_microk8s-namespaces-add-msg:
	$(info ### Create namespace "$(value K8S_NAMESPACE)" in MicroK8s ...)
microk8s-namespace-add:
	$(call check-defined,K8S_NAMESPACE)
	@$(MAKE) _microk8s-namespaces-add-msg _microk8s-namespace-add
_microk8s-namespace-add: UK8S_CMD = kubectl create namespace "$(K8S_NAMESPACE)"

# Delete a namespace from the MicroK8s cluster.
#
_microk8s-namespaces-del-msg:
	$(info ### Deleting namespace "$(value K8S_NAMESPACE)" in MicroK8s ...)
microk8s-namespace-del:
	$(call check-defined,K8S_NAMESPACE)
	$(MAKE) _microk8s-namespaces-del-msg _microk8s-namespace-del
_microk8s-namespace-del: UK8S_CMD = kubectl delete namespace "$(K8S_NAMESPACE)"

# Deploy and Access the Kubernetes dashboard.
#
_microk8s-dashboard-proxy-msg:
	$(info ### MicroK8s CLI-blocking Kubernetes dashboard...)
microk8s-dashboard-proxy: _microk8s-dashboard-proxy-msg _microk8s-dashboard-proxy
_microk8s-dashboard-proxy: UK8S_CMD = dashboard-proxy

# Deploy and Access the Kubernetes dashboard.
#
# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
_microk8s-addon-dashboard-msg:
	$(info ### Enabling the MicroK8s dashboard addon ...)
_microk8s-addon-dashboard: _microk8s-addon-dashboard-msg
_microk8s-addon-dashboard: UK8S_CMD = enable dashboard

# Get the Kubernetes dashboard credentials.
#
_microk8s-dashboard-creds-msg:
	$(info ### Login to the MicroK8s Kubernetes dashboard with following token:)
microk8s-dashboard-creds: _microk8s-dashboard-creds-msg _microk8s-dashboard-creds
_microk8s-dashboard-creds: UK8S_CMD = kubectl create token default

MICROK8S_DASHBOARD_PORT ?= 19443
microk8s-addon-dashboard:
	$(MAKE) _microk8s-addon-dashboard
	$(MAKE) _microk8s-addon-dashboard-wait
	$(MAKE) microk8s-pod-wait

# Establish the Kubernetes dashboard port-forward and backoff until port is in service.
microk8s-dashboard: _microk8s-reset-dashboard microk8s-addon-dashboard _microk8s-dashboard-msg
	$(MAKE) _microk8s-dashboard _microk8s-dashboard-backoff
	$(MAKE) microk8s-dashboard-creds
_microk8s-dashboard-msg: makester-work-dir
	$(info ### Kubernetes dashboard address forwarded to: https://$(MAKESTER__LOCAL_IP):$(MICROK8S_DASHBOARD_PORT))
	$(info ### Kubernetes dashboard log output can be found at $(MAKESTER__WORK_DIR)/microk8s-dashboard.out)
_microk8s-dashboard: UK8S_CMD = kubectl port-forward svc/kubernetes-dashboard\
 -n kube-system $(MICROK8S_DASHBOARD_PORT):443\
 --address="0.0.0.0" > $(MAKESTER__WORK_DIR)/microk8s-dashboard.out 2>&1 &

_microk8s-reset-dashboard:
	-$(shell which pkill) -f "port-forward svc/kubernetes-dashboard"

_microk8s-addon-dashboard-wait:
	$(info ### Waiting for Kubernetes dashboard service ...)
	$(call _microk8s-addon-dashboard-wait-cmd)

define _microk8s-addon-dashboard-wait-cmd
	until [ $$($(MAKESTER__MICROK8S) status --addon dashboard) = enabled ]; do sleep 2; done
endef

# Wait for the kubernetes-dashboard pod in the kube-system namespace be to in the ready state.
#
microk8s-pod-wait:
	$(info ### Waiting for Kubernetes pods in kube-system namespace to be ready ...)
	$(call _microk8s-pod-wait-cmd)
define _microk8s-pod-wait-cmd
	until [ "$$($(MAKESTER__MICROK8S) kubectl wait -n kube-system --for=condition=ready pod --all 2>/dev/null | grep kubernetes-dashboard | cut -f 2- -d\ )" = "condition met" ]; do sleep 2; done
endef

# Check the version of MicroK8s.
microk8s-version: UK8S_CMD = kubectl version --short

_microk8s-dashboard-backoff:
	$(MAKESTER__BIN)/makester backoff $(MAKESTER__LOCAL_IP) $(MICROK8S_DASHBOARD_PORT) --detail "MicroK8s Kubernetes dashboard"

microk8s-dashboard-stop:
	$(info ### Closing MicroK8s dashboard port-forward at https://$(MAKESTER__LOCAL_IP):$(MICROK8S_DASHBOARD_PORT))
	$(MAKE) _microk8s-reset-dashboard

# All-in-one helper to start required MicroK8s services.
#
microk8s-up:
	@$(MAKE) microk8s-install
	@$(MAKE) microk8s-start
	@$(MAKE) microk8s-addon-dns
	@$(MAKE) microk8s-dashboard
	
# All-in-one helper to reset MicroK8s and stop services.
microk8s-down:
	@$(MAKE) microk8s-dashboard-stop
ifeq ($(MAKESTER__UNAME),Darwin)
	@$(MAKE) microk8s-reset
endif
	@$(MAKE) microk8s-stop
	@$(MAKE) microk8s-uninstall

_microk8s-addon-dashboard\
 _microk8s-addon-dns\
 _microk8s-dashboard-creds\
 _microk8s-dashboard\
 _microk8s-dashboard-proxy\
 _microk8s-install\
 _microk8s-namespaces\
 _microk8s-namespace-add\
 _microk8s-namespace-del\
 _microk8s-reset\
 _microk8s-start\
 _microk8s-status\
 _microk8s-stop\
 _microk8s-uninstall\
 _microk8s-wait\
 microk8s-version: _uk8s-cmd

microk8s-help:
	@echo "($(MAKESTER__MAKEFILES)/microk8s.mk)\n\
  microk8s-addon-dashboard\n\
                       Enable the MicroK8s DNS addon\n\
  microk8s-addon-dns   Enable the MicroK8s DNS addon\n\
  microk8s-dashboard   MicroK8s Kubernetes dashboard as a background service\n\
  microk8s-dashboard-creds\n\
                       Display the MicroK8s Kubernetes dashboard auth token\n\
  microk8s-dashboard-proxy\n\
                       MicroK8s CLI-blocking Kubernetes dashboard\n\
  microk8s-down        All-in-one helper to stop and release MicroK8s service resources\n\
  microk8s-install     Setup MicroK8s VM with default options\n\
  microk8s-kubectl-version\n\
		       Print the installed MicroK8s version and revision number\n\
  microk8s-namespaces  List the namespaces in the MicroK8s cluster\n\
  microk8s-namespace-add\n\
                       Create namespace defined by \"K8S_NAMESPACES\" in MicroK8s cluster\n\
  microk8s-namespace-del\n\
                       Delete namespace defined by \"K8S_NAMESPACES\" from MicroK8s cluster\n\
  microk8s-reset       Return the MicroK8s node to the default initial state\n\
  microk8s-start       Starts the kubernetes cluster\n\
  microk8s-status      Displays the status of the cluster\n\
  microk8s-stop        Stop Kubernetes\n\
  microk8s-up          All-in-one helper to start required MicroK8s services\n\
  microk8s-version     Print the installed MicroK8s version and revision number\n\
  microk8s-wait        Wait for the Kubernetes services to initialise\n"

.PHONY: microk8s-help
