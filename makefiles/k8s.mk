MINIKUBE := $(shell which minikube)
KUBECTL := $(shell which kubectl)
KOMPOSE := $(shell which kompose)

minikube-cmd:
	-@$(MINIKUBE) $(MK_CMD) || true

mk-status: MK_CMD = status
mk-start: MK_CMD = start --driver docker
mk-dashboard: MK_CMD = dashboard
mk-stop: MK_CMD = stop
mk-del: MK_CMD = delete
mk-del: kube-del
mk-service: MK_CMD = service $(MAKESTER__PROJECT_NAME) --url
mk-status mk-start mk-dashboard mk-stop mk-del mk-service: minikube-cmd

kubectl-cmd:
	-$(KUBECTL) $(KCTL_CMD) || true

kube-apply: KCTL_CMD = apply -f ./k8s
kube-apply: mk-start
kube-del: KCTL_CMD = delete -f ./k8s
kube-get: KCTL_CMD = get pod,svc
kube-apply kube-del kube-get: kubectl-cmd

kompose-cmd:
	$(KOMPOSE) $(KOMPOSE_CMD) || true

mkdir-k8s:
	-@$(shell which mkdir) ./k8s 2>/dev/null || true

konvert: mkdir-k8s
konvert: KOMPOSE_CMD = convert --out ./k8s
konvert: kompose-cmd

k8s-help:
	@echo "(makefiles/k8s.mk)\n\
  mk-status            Check Minikube local cluster status\n\
  mk-start             Start Minikube locally and create a cluster (docker driver)\n\
  mk-dashboard         Access the Kubernetes Dashboard (Ctrl-C to stop)\n\
  mk-stop              Stop Minikube local cluster\n\
  mk-del               Delete Minikube local cluster\n\
  mk-service           Get Service access details (if \"LoadBalancer\" type specified)\n\
  konvert              Convert config files from \"docker-compose.yml\"\n\
  kube-apply           Create resource(s) in all manifest files in \"./k8s\" directory\n\
  kube-del             Delete a pod using the type and name specified in \"./k8s\" directory\n\
  kube-get             View the Pods and Services\n"

.PHONY: k8s-help konvert
