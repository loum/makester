ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := argocd-help
endif

ifndef MAKESTER__PRIMED
$(info ### Add the following include statement to your Makefile)
$(info include makester/makefiles/makester.mk)
$(error ### missing include dependency)
endif

MAKESTER__ARGOCD_EXE_NAME ?= argocd
MAKESTER__ARGOCD_EXE_INSTALL ?= https://argo-cd.readthedocs.io/en/stable/cli_installation/
MAKESTER__ARGOCD ?= $(call check-exe,$(MAKESTER__ARGOCD_EXE_NAME),$(MAKESTER__ARGOCD_EXE_INSTALL),optional)

# Loosely based on:
# https://argo-cd.readthedocs.io/en/stable/getting_started/
_argocd-cmd:
	$(if $(MAKESTER__ARGOCD),,$(call _argocd-cmd-err))
	$(MAKESTER__ARGOCD) $(ARGOCD_CMD)

define _argocd-cmd-err
	$(info ### MAKESTER__ARGOCD: <undefined>)
	$(info ### MAKESTER__ARGOCD_EXE_NAME set as "$(MAKESTER__ARGOCD_EXE_NAME)")
	$(call check-exe,$(MAKESTER__ARGOCD_EXE_NAME),$(MAKESTER__ARGOCD_EXE_INSTALL))
endef

# Create the ArgoCD namesace, "argocd" in Kubernetes.
#
argocd-ns:
	-$(MAKE) K8S_NAMESPACE=argocd microk8s-namespace-add

# Delete the ArgoCD namesace, "argocd" in Kubernetes.
#
argocd-ns-del:
	-@$(MAKE) K8S_NAMESPACE=argocd microk8s-namespace-del

_argcd_github ?= https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
_argocd-install-msg:
	$(info ### Installing Argo CD API Server to the "argocd" namespace)
argocd-install: _argocd-install-msg _argocd-install
_argocd-install: UK8S_CMD = kubectl apply -n argocd -f $(_argcd_github)

# Convenience target to install a fully functional ArgoCD instance on MicroK8s.
#
argocd-deploy:
	$(info ### Installing ArgoCD instance on MicroK8s ...)
	$(MAKE) microk8s-addon-dns
	$(MAKE) argocd-ns
	$(MAKE) argocd-install
	$(MAKE) _argocd-pod-wait

_argocd-creds-msg:
	$(info ### Login to the Argo CD API Server as user "admin" with following password:)
argocd-creds: _argocd-creds-msg _argocd-creds
_argocd-creds: UK8S_CMD = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# Wait for the argocd-server pod in the argocd namespace be to in the ready state.
#
_argocd-pod-wait:
	$(info ### Waiting for argocd-server pod in argocd namespace to be ready ...)
	$(call _argocd-pod-wait-cmd)
define _argocd-pod-wait-cmd
  until [ "$$($(MAKESTER__MICROK8S) kubectl wait -n argocd --for=condition=ready pod --all 2>/dev/null | grep argocd-server | cut -f 2- -d\ )" = "condition met" ]; do sleep 2; done
endef

# Expose the Argo CD API server.
#
MAKESTER__ARGOCD_DASHBOARD_PORT ?= 20443
argocd-dashboard: _argocd-reset-dashboard
	$(MAKE) _argocd-dashboard _argocd-backoff _argocd-dashboard-msg
	$(MAKE) argocd-creds
_argocd-dashboard-msg:
	$(info ### Argo CD API Server address forwarded to: https://$(MAKESTER__LOCAL_IP):$(MAKESTER__ARGOCD_DASHBOARD_PORT))
	$(info ### Argo CD API Server log output can be found at $(MAKESTER__WORK_DIR)/argocd-dashboard.out)
_argocd-dashboard: UK8S_CMD = kubectl port-forward svc/argocd-server\
 -n argocd $(MAKESTER__ARGOCD_DASHBOARD_PORT):443\
 --address="0.0.0.0" > $(MAKESTER__WORK_DIR)/argocd-dashboard.out 2>&1 &

_argocd-reset-dashboard:
	-$(shell which pkill) -f "port-forward svc/argocd-server"

# Stop the Argo CD API server port-forward.
#
argocd-dashboard-stop:
	$(info ### Closing Argo CD API Server port-forward at https://$(MAKESTER__LOCAL_IP):$(MAKESTER__ARGOCD_DASHBOARD_PORT))
	$(MAKE) _argocd-reset-dashboard

# Authenticate to the Argo CD API server via the CLI.
#
argocd-cli-login: _argocd-cli-login-msg _argocd-creds _argocd-cli-login
_argocd-cli-login-msg:
	$(info ### Login to the Argo CD CLI as user "admin" with following password:)
_argocd-cli-login: ARGOCD_CMD = login $(MAKESTER__LOCAL_IP):$(MAKESTER__ARGOCD_DASHBOARD_PORT) --insecure

# Deploy a sample app with Argo CD.
#
argocd-example: _argocd-example-msg
	$(MAKE) argocd-cli-login
	$(MAKE) _argocd-example
	$(MAKE) _argocd-example-sync
_argocd-example-msg:
	$(info ### Argo CD creating example application ...)
_argocd-example: ARGOCD_CMD = app create guestbook\
 --repo https://github.com/argoproj/argocd-example-apps.git\
 --path guestbook\
 --dest-server https://kubernetes.default.svc\
 --dest-namespace default
_argocd-example-sync: ARGOCD_CMD = app sync guestbook

# Expose the sample app via MicroK8s port-forward.
#
argocd-example-ui: _argocd-example-ui-msg _argocd-example-ui
_argocd-example-ui-msg:
	$(info ### Argo CD Example App UI: http://$(MAKESTER__LOCAL_IP):20888 (Ctrl-C to stop))
_argocd-example-ui: UK8S_CMD = kubectl port-forward svc/guestbook-ui -n argocd 20888:80 --address='0.0.0.0' --namespace default

# Delete the sample app with Argo CD.
#
argocd-example-del: _argocd-example-del-msg
	$(MAKE) argocd-cli-login
	$(MAKE) _argocd-example-del
_argocd-example-del-msg:
	$(info ### Deleting Argo CD Example App ...)
_argocd-example-del: ARGOCD_CMD = app delete guestbook --cascade --yes

# Argo CD all-in-one deployment helper.
#
argocd-up:
	$(info ### Argo CD deployment and API server setup ...)
	$(MAKE) argocd-deploy
	$(MAKE) argocd-dashboard

# Argo CD clean up.
#
argocd-down:
	$(info ### Argo CD deployment clean up ...)
	$(MAKE) argocd-ns-del

_argocd-example-ui _argocd-dashboard _argocd-creds _argocd-install _argocd-ns _argocd-ns-del: _uk8s-cmd
_argocd-example-del _argocd-example-sync _argocd-example _argocd-cli-login: _argocd-cmd

_argocd-backoff:
	venv/bin/makester backoff $(MAKESTER__LOCAL_IP) $(MAKESTER__ARGOCD_DASHBOARD_PORT) --detail "Argo CD API server"

_argocd-example-backoff:
	venv/bin/makester backoff $(MAKESTER__LOCAL_IP) 20888 --detail "Argo CD Example App"

argocd-help:
	@echo "(makefiles/argocd.mk)\n\
  argocd-cli-login     Login to the Argo CD CLI\n\
  argocd-creds         Dump the Argo CD credentials in plain-text\n\
  argocd-dashboard     Start the Argo CD API server at https://$(MAKESTER__LOCAL_IP):$(MAKESTER__ARGOCD_DASHBOARD_PORT)\n\
  argocd-dashboard-stop\n\
                       Stop the Argo CD API server at https://$(MAKESTER__LOCAL_IP):$(MAKESTER__ARGOCD_DASHBOARD_PORT)\n\
  argocd-deploy        Convenience all-in-one target to stand up an ArgoCD instance\n\
  argocd-down          Argo CD deployment clean up\n\
  argocd-example       Create the Argo CD example guestbook application\n\
  argocd-example-del   Delete the Argo CD example guestbook application\n\
  argocd-example-ui    Start the Argo CD example guestbook application UI\n\
  argocd-install       Install an ArgoCD instance into the \"argocd\" namespace\n\
  argocd-ns            Create the \"argocd\" namespace\n\
  argocd-ns-del        Delete the \"argocd\" namespace\n\
  argocd-up            Argo CD deployment and API server setup\n"

.PHONY: argocd-help
