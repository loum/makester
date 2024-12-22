# ArgoCD test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags argocd tests
#
# bats file_tags=argocd
setup() {
  load 'test_helper/common-setup'
  _common_setup
}

# ArgoCD include dependencies.
#
# Makester.
# bats test_tags=argocd-dependencies
@test "Check if Makester is primed: false" {
    run make -f makefiles/argocd.mk

    assert_output --partial '### Add the following include statement to your Makefile
include makester/makefiles/makester.mk'

    assert_failure
}
# bats test_tags=argocd-dependencies
@test "Check if Makester is primed: true" {
    run make -f makefiles/makester.mk argocd-help

    assert_output --partial '(makefiles/argocd.mk)'

    assert_success
}

# ArgoCD variables.
#
# bats test_tags=variables,argocd-variables,MAKESTER__ARGOCD_EXE_NAME
@test "MAKESTER__ARGOCD_EXE_NAME default should be set when calling argocd.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__ARGOCD_EXE_NAME

    assert_output 'MAKESTER__ARGOCD_EXE_NAME=argocd'

    assert_success
}
# bats test_tags=variables,argocd-variables,MAKESTER__ARGOCD_EXE_NAME
@test "MAKESTER__ARGOCD_EXE_NAME override" {
    MAKESTER__ARGOCD_EXE_NAME=/usr/local/bin/argocd\
 run make -f makefiles/makester.mk print-MAKESTER__ARGOCD_EXE_NAME

    assert_output 'MAKESTER__ARGOCD_EXE_NAME=/usr/local/bin/argocd'

    assert_success
}

# bats test_tags=variables,argocd-variables,MAKESTER__ARGOCD_EXE_INSTALL
@test "MAKESTER__ARGOCD_EXE_INSTALL default should be set when calling k8s.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__ARGOCD_EXE_INSTALL

    assert_output 'MAKESTER__ARGOCD_EXE_INSTALL=https://argo-cd.readthedocs.io/en/stable/cli_installation/'

    assert_success
}
# bats test_tags=variables,argocd-variables,MAKESTER__ARGOCD_EXE_INSTALL
@test "MAKESTER__ARGOCD_EXE_INSTALL override" {
    MAKESTER__ARGOCD_EXE_INSTALL=http://localhost:8000\
 run make -f makefiles/makester.mk print-MAKESTER__ARGOCD_EXE_INSTALL

    assert_output 'MAKESTER__ARGOCD_EXE_INSTALL=http://localhost:8000'

    assert_success
}

# Targets.
#
# bats test_tags=targets,argocd-targets,argocd-ns,dry-run
@test "Create 'argocd' namespace in MicroK8s cluster: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk argocd-ns --dry-run

    assert_output --regexp 'make K8S_NAMESPACE=argocd microk8s-namespace-add

.*make _microk8s-namespaces-add-msg _microk8s-namespace-add
### Create namespace "argocd" in MicroK8s ...

microk8s kubectl create namespace "argocd"'

    assert_success
}

# bats test_tags=targets,argocd-targets,argocd-ns-del,dry-run
@test "Delete 'argocd' namespace from MicroK8s cluster: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk argocd-ns-del --dry-run

    assert_output --regexp 'make K8S_NAMESPACE=argocd microk8s-namespace-del

.*make _microk8s-namespaces-del-msg _microk8s-namespace-del
### Deleting namespace "argocd" in MicroK8s ...

microk8s kubectl delete namespace "argocd"'

    assert_success
}

# bats test_tags=targets,argocd-targets,argocd-deploy,dry-run
@test "Convenience target to install a fully functional ArgoCD instance on MicroK8s: dry" {
    MAKESTER__MICROK8S=microk8s MAKESTER__ARGOCD=argocd\
 run make -f makefiles/makester.mk argocd-deploy --dry-run

    assert_output --regexp '### Installing ArgoCD instance on MicroK8s ...
.*make microk8s-addon-dns
### Enabling the MicroK8s DNS addon ...

microk8s enable dns
### Checking MicroK8s status ...
.*make argocd-ns
.*make K8S_NAMESPACE=argocd microk8s-namespace-add

.*make _microk8s-namespaces-add-msg _microk8s-namespace-add
### Create namespace "argocd" in MicroK8s ...

microk8s kubectl create namespace "argocd"
.*make argocd-install
### Installing Argo CD API Server to the "argocd" namespace

microk8s kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
make _argocd-pod-wait
### Waiting for argocd-server pod in argocd namespace to be ready ...

until \[ "\$\(microk8s kubectl wait -n argocd --for=condition=ready pod --all 2>/dev/null | grep argocd-server | cut -f 2- -d\ )" = "condition met" ]; do sleep 2; done'

    assert_success
}

# bats test_tags=targets,argocd-targets,argocd-dashboard,dry-run
@test "Expose the Argo CD API server: dry" {
    MAKESTER__MICROK8S=microk8s MAKESTER__ARGOCD=argocd\
 run make -f makefiles/makester.mk argocd-dashboard --dry-run

    assert_output --regexp 'pkill -f "port-forward svc/argocd-server"
.*make _argocd-dashboard _argocd-backoff _argocd-dashboard-msg

microk8s kubectl port-forward svc/argocd-server -n argocd 20443:443 --address="0.0.0.0" > /.*/.makester/argocd-dashboard.out 2>&1 &
.*/bin/makester backoff [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ 20443 --detail "Argo CD API server"
### Argo CD API Server address forwarded to: https://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:20443
### Argo CD API Server log output can be found at /.*/.makester/argocd-dashboard.out


.*make argocd-creds
### Login to the Argo CD API Server as user "admin" with following password:

microk8s kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="\{.data.password\}" \| base64 -d; echo'

    assert_success
}
# bats test_tags=targets,argocd-targets,argocd-dashboard,dry-run
@test "Expose the Argo CD API server override MAKESTER__ARGOCD_DASHBOARD_PORT: dry" {
    MAKESTER__MICROK8S=microk8s MAKESTER__ARGOCD=argocd MAKESTER__ARGOCD_DASHBOARD_PORT=9999\
 run make -f makefiles/makester.mk argocd-dashboard --dry-run

    assert_output --regexp 'pkill -f "port-forward svc/argocd-server"
.*make _argocd-dashboard _argocd-backoff _argocd-dashboard-msg

microk8s kubectl port-forward svc/argocd-server -n argocd 9999:443 --address="0.0.0.0" > /.*/.makester/argocd-dashboard.out 2>&1 &
.*/bin/makester backoff [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ 9999 --detail "Argo CD API server"
### Argo CD API Server address forwarded to: https://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:9999
### Argo CD API Server log output can be found at /.*/.makester/argocd-dashboard.out


.*make argocd-creds
### Login to the Argo CD API Server as user "admin" with following password:

microk8s kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="\{.data.password\}" \| base64 -d; echo'

    assert_success
}

# bats test_tags=targets,argocd-targets,argocd-dashboard-stop,dry-run
@test "Stop the Argo CD API server port-forward: dry" {
    MAKESTER__ARGOCD=argocd run make -f makefiles/makester.mk argocd-dashboard-stop --dry-run

    assert_output --regexp '### Closing Argo CD API Server port-forward at https://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:20443
.*make _argocd-reset-dashboard
/.*/pkill -f "port-forward svc/argocd-server"'

    assert_success
}
# bats test_tags=targets,argocd-targets,argocd-dashboard-stop,dry-run
@test "Stop the Argo CD API server port-forward override MAKESTER__ARGOCD_DASHBOARD_PORT: dry" {
    MAKESTER__ARGOCD=argocd MAKESTER__ARGOCD_DASHBOARD_PORT=9999\
 run make -f makefiles/makester.mk argocd-dashboard-stop --dry-run

    assert_output --regexp '### Closing Argo CD API Server port-forward at https://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:9999
.*make _argocd-reset-dashboard
/.*/pkill -f "port-forward svc/argocd-server"'

    assert_success
}

# bats test_tags=targets,argocd-targets,argocd-cli-login,dry-run
@test "Authenticate to the Argo CD API server via the CLI: dry" {
    MAKESTER__MICROK8S=microk8s MAKESTER__ARGOCD=argocd\
 run make -f makefiles/makester.mk argocd-cli-login --dry-run

    assert_output --regexp '### Login to the Argo CD CLI as user "admin" with following password:
microk8s kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="\{.data.password\}" \| base64 -d; echo
argocd login [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:20443 --insecure'

    assert_success
}
