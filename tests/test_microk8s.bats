# MicroK8s test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags microk8s tests
#
# bats file_tags=microk8s
setup_file() {
    export MAKESTER__WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/makester-XXXXXX")
}
setup() {
  load 'test_helper/common-setup'
  _common_setup
}
teardown_file() {
    MAKESTER__WORK_DIR=$MAKESTER__WORK_DIR make -f makefiles/makester.mk makester-work-dir-rm
}

# MicroK8s include dependencies.
#
# Makester.
# bats test_tags=microk8s-dependencies
@test "Check if Makester is primed: false" {
    run make -f makefiles/microk8s.mk

    assert_output --partial '### Add the following include statement to your Makefile
include makester/makefiles/makester.mk'

    assert_failure
}
# bats test_tags=microk8s-dependencies
@test "Check if Makester is primed: true" {
    run make -f makefiles/makester.mk microk8s-help

    assert_output --partial '(makefiles/microk8s.mk)'

    assert_success
}

# MicroK8s variables.
#
# bats test_tags=variables,microk8s-variables,MAKESTER__MICROK8S_EXE_NAME
@test "MAKESTER__MICROK8S_EXE_NAME default should be set when calling k8s.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__MICROK8S_EXE_NAME

    assert_output 'MAKESTER__MICROK8S_EXE_NAME=microk8s'

    assert_success
}
# bats test_tags=variables,microk8s-variables,MAKESTER__MICROK8S_EXE_NAME
@test "MAKESTER__MICROK8S_EXE_NAME override" {
    MAKESTER__MICROK8S_EXE_NAME=/usr/local/bin/microk8s\
 run make -f makefiles/makester.mk print-MAKESTER__MICROK8S_EXE_NAME

    assert_output 'MAKESTER__MICROK8S_EXE_NAME=/usr/local/bin/microk8s'

    assert_success
}

# bats test_tags=variables,microk8s-variables,MAKESTER__MICROK8S_EXE_INSTALL
@test "MAKESTER__MICROK8S_EXE_INSTALL default should be set when calling k8s.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__MICROK8S_EXE_INSTALL

    assert_output 'MAKESTER__MICROK8S_EXE_INSTALL=https://microk8s.io/docs/getting-started'

    assert_success
}
# bats test_tags=variables,microk8s-variables,MAKESTER__MICROK8S_EXE_INSTALL
@test "MAKESTER__MICROK8S_EXE_INSTALL override" {
    MAKESTER__MICROK8S_EXE_INSTALL=http://localhost:8000\
 run make -f makefiles/makester.mk print-MAKESTER__MICROK8S_EXE_INSTALL

    assert_output 'MAKESTER__MICROK8S_EXE_INSTALL=http://localhost:8000'

    assert_success
}

# bats test_tags=variables,microk8s-variables,MICROK8S_DASHBOARD_PORT
@test "MICROK8S_DASHBOARD_PORT default should be set when calling k8s.mk" {
    run make -f makefiles/makester.mk print-MICROK8S_DASHBOARD_PORT

    assert_output 'MICROK8S_DASHBOARD_PORT=19443'

    assert_success
}
# bats test_tags=variables,microk8s-variables,MICROK8S_DASHBOARD_PORT
@test "MICROK8S_DASHBOARD_PORT override" {
    MICROK8S_DASHBOARD_PORT=19449\
 run make -f makefiles/makester.mk print-MICROK8S_DASHBOARD_PORT

    assert_output 'MICROK8S_DASHBOARD_PORT=19449'

    assert_success
}

# Targets.
#
# bats test_tags=targets,microk8s-targets,microk8s-status,dry-run
@test "Microk8s status when executable not found: dry" {
    MAKESTER__MICROK8S_EXE_NAME=dummy run make -f makefiles/makester.mk microk8s-status --dry-run

    assert_output --regexp '^### Checking MicroK8s status ...
### MAKESTER__MICROK8S: <undefined>
### MAKESTER__MICROK8S_EXE_NAME set as "dummy"
### "dummy" not found
### Install notes: https://microk8s.io/docs/getting-started
makefiles/microk8s.mk:[0-9]+: \*\*\* ###.  Stop.$'

    assert_failure
}
# bats test_tags=targets,microk8s-targets,microk8s-status,dry-run
@test "Microk8s status: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-status --dry-run

    assert_output '### Checking MicroK8s status ...
microk8s status'

    assert_success
}

# bats test_tags=targets,microk8s-targets,microk8s-install,dry-run
@test "Microk8s install for Darwin: dry" {
    MAKESTER__UNAME=Darwin MAKESTER__LOCAL_IP=192.168.1.1 MAKESTER__MICROK8S=microk8s\
 run make -f makefiles/makester.mk microk8s-install --dry-run

    assert_output 'make _microk8s-install-msg _microk8s-install
### Installing MicroK8s ...

microk8s install --cpu 2 --mem 4 --channel "1.28/stable" --image 22.04 --disk 50'

    assert_success
}
# bats test_tags=targets,microk8s-targets,microk8s-install,dry-run
@test "Microk8s install for Darwin with overridden settings: dry" {
    MAKESTER__UNAME=Darwin MULTIPASS_CPU=4 MULTIPASS_MEMORY=8 MULTIPASS_CHANNEL="1.30/stable"\
 MULTIPASS_IMAGE=24.04 MULTIPASS_DISK=100\
 MAKESTER__LOCAL_IP=192.168.1.1 MAKESTER__MICROK8S=microk8s\
 run make -f makefiles/makester.mk microk8s-install --dry-run

    assert_output 'make _microk8s-install-msg _microk8s-install
### Installing MicroK8s ...

microk8s install --cpu 4 --mem 8 --channel "1.30/stable" --image 24.04 --disk 100'

    assert_success
}
# bats test_tags=targets,microk8s-targets,microk8s-install,dry-run
@test "Microk8s install for Linux: dry" {
    MAKESTER__UNAME=Linux MAKESTER__LOCAL_IP=192.168.1.1 MAKESTER__MICROK8S=microk8s\
 run make -f makefiles/makester.mk microk8s-install --dry-run

    assert_output ''

    assert_success
}

# bats test_tags=targets,microk8s-targets,microk8s-uninstall,dry-run
@test "Microk8s uninstall for Darwin: dry" {
    MAKESTER__UNAME=Darwin MAKESTER__LOCAL_IP=192.168.1.1 MAKESTER__MICROK8S=microk8s\
 run make -f makefiles/makester.mk microk8s-uninstall --dry-run

    assert_output --partial 'make _microk8s-uninstall-msg _microk8s-uninstall
### Uninstalling MicroK8s ...

microk8s uninstall'

    assert_success
}
# bats test_tags=targets,microk8s-targets,microk8s-uninstall,dry-run
@test "Microk8s uninstall for Linux: dry" {
    MAKESTER__UNAME=Linux MAKESTER__LOCAL_IP=192.168.1.1 MAKESTER__MICROK8S=microk8s\
 run make -f makefiles/makester.mk microk8s-uninstall --dry-run

    assert_output ''

    assert_success
}

# bats test_tags=targets,microk8s-targets,microk8s-wait,dry-run
@test "Microk8s status and wait for Kubernetes services: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-wait --dry-run

    assert_output '### Checking MicroK8s status ...
microk8s status --wait-ready'

    assert_success
}

# bats test_tags=targets,microk8s-targets,microk8s-start,dry-run
@test "Microk8s start: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-start --dry-run

    assert_output --regexp '^### Starting MicroK8s ...
microk8s start
.*make microk8s-wait
### Checking MicroK8s status ...

microk8s status --wait-ready$'

    assert_success
}

# bats test_tags=targets,microk8s-targets,microk8s-dashboard-proxy,dry-run
@test "Microk8s dashboard proxy: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-dashboard-proxy --dry-run

    assert_output '### MicroK8s CLI-blocking Kubernetes dashboard...
microk8s dashboard-proxy'

    assert_success
}

# bats test_tags=targets,microk8s-targets,microk8s-dashboard-creds,dry-run
@test "Microk8s dashboard authorisation token: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-dashboard-creds --dry-run

    assert_output '### Login to the MicroK8s Kubernetes dashboard with following token:
microk8s kubectl create token default'

    assert_success
}

# bats test_tags=targets,microk8s-targets,microk8s-dashboard,dry-run
@test "Makester Microk8s dashboard: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-dashboard --dry-run

    assert_output --regexp 'pkill -f "port-forward svc/kubernetes-dashboard"
.*make _microk8s-addon-dashboard
### Enabling the MicroK8s dashboard addon ...

microk8s enable dashboard
.*make _microk8s-addon-dashboard-wait
### Waiting for Kubernetes dashboard service ...

until \[ \$\(microk8s status --addon dashboard\) = enabled \]; do sleep 2; done
.*make microk8s-pod-wait
### Waiting for Kubernetes pods in kube-system namespace to be ready ...

until \[ "\$\(microk8s kubectl wait -n kube-system --for=condition=ready pod --all 2>/dev/null \| grep kubernetes-dashboard \| cut -f 2- -d\\ \)" = "condition met" \]; do sleep 2; done
### Creating Makester working directory "'$MAKESTER__WORK_DIR'"
/.*/mkdir -pv '$MAKESTER__WORK_DIR'
### Kubernetes dashboard address forwarded to: https://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:19443
### Kubernetes dashboard log output can be found at '$MAKESTER__WORK_DIR'/microk8s-dashboard.out
.*make _microk8s-dashboard _microk8s-dashboard-backoff

microk8s kubectl port-forward svc/kubernetes-dashboard -n kube-system 19443:443 --address="0.0.0.0" > '$MAKESTER__WORK_DIR'/microk8s-dashboard.out 2>&1 &
.*/bin/makester backoff [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ 19443 --detail "MicroK8s Kubernetes dashboard"
.*make microk8s-dashboard-creds
### Login to the MicroK8s Kubernetes dashboard with following token:

microk8s kubectl create token default'

    assert_success
}
# bats test_tags=targets,microk8s-targets,microk8s-dashboard,dry-run
@test "Makester Microk8s dashboard override MICROK8S_DASHBOARD_PORT: dry" {
    MAKESTER__MICROK8S=microk8s MICROK8S_DASHBOARD_PORT=19999\
 run make -f makefiles/makester.mk microk8s-dashboard --dry-run

    assert_output --regexp 'pkill -f "port-forward svc/kubernetes-dashboard"
.*make _microk8s-addon-dashboard
### Enabling the MicroK8s dashboard addon ...

microk8s enable dashboard
.*make _microk8s-addon-dashboard-wait
### Waiting for Kubernetes dashboard service ...

until \[ \$\(microk8s status --addon dashboard\) = enabled \]; do sleep 2; done
.*make microk8s-pod-wait
### Waiting for Kubernetes pods in kube-system namespace to be ready ...

until \[ "\$\(microk8s kubectl wait -n kube-system --for=condition=ready pod --all 2>/dev/null \| grep kubernetes-dashboard \| cut -f 2- -d\\ \)" = "condition met" \]; do sleep 2; done
### Creating Makester working directory "'$MAKESTER__WORK_DIR'"
/.*/mkdir -pv '$MAKESTER__WORK_DIR'
### Kubernetes dashboard address forwarded to: https://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:19999
### Kubernetes dashboard log output can be found at '$MAKESTER__WORK_DIR'/microk8s-dashboard.out
.*make _microk8s-dashboard _microk8s-dashboard-backoff

microk8s kubectl port-forward svc/kubernetes-dashboard -n kube-system 19999:443 --address="0.0.0.0" > '$MAKESTER__WORK_DIR'/microk8s-dashboard.out 2>&1 &
.*/bin/makester backoff [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ 19999 --detail "MicroK8s Kubernetes dashboard"
.*make microk8s-dashboard-creds
### Login to the MicroK8s Kubernetes dashboard with following token:

microk8s kubectl create token default'

    assert_success
}

# bats test_tags=targets,microk8s-targets,microk8s-addon-dashboard,dry-run
@test "Microk8s addon for dashboard: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-addon-dashboard --dry-run

    assert_output --regexp '.*make _microk8s-addon-dashboard
### Enabling the MicroK8s dashboard addon ...

microk8s enable dashboard
.*make _microk8s-addon-dashboard-wait
### Waiting for Kubernetes dashboard service ...

until \[ \$\(microk8s status --addon dashboard\) = enabled \]; do sleep 2; done
.*make microk8s-pod-wait
### Waiting for Kubernetes pods in kube-system namespace to be ready ...

until \[ "\$\(microk8s kubectl wait -n kube-system --for=condition=ready pod --all 2>/dev/null \| grep kubernetes-dashboard \| cut -f 2- -d\\ \)" = "condition met" \]; do sleep 2; done'

    assert_success
}

# bats test_tags=targets,microk8s-targets,microk8s-addon-dns,dry-run
@test "Microk8s addon for dns: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-addon-dns --dry-run

    assert_output '### Enabling the MicroK8s DNS addon ...
microk8s enable dns
### Checking MicroK8s status ...'

    assert_success
}

# bats test_tags=targets,microk8s-targets,microk8s-namespaces,dry-run
@test "Microk8s namespaces: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-namespaces --dry-run

    assert_output '### Display all active namespaces in MicroK8s ...
microk8s kubectl get namespace'

    assert_success
}

# bats test_tags=targets,microk8s-targets,microk8s-namespace-add,dry-run
@test "Microk8s namespace add with missing K8S_NAMESPACE: dry" {
    MAKESTER__MICROK8S=microk8s\
 run make -f makefiles/makester.mk microk8s-namespace-add --dry-run

    assert_output --regexp '### "K8S_NAMESPACE" undefined
### 
makefiles/microk8s.mk:[0-9]+: \*\*\* ###.  Stop.'

    assert_failure
}
# bats test_tags=targets,microk8s-targets,microk8s-namespace-add,dry-run
@test "Microk8s namespace add with K8S_NAMESPACE set: dry" {
    MAKESTER__MICROK8S=microk8s K8S_NAMESPACE=argocd\
 run make -f makefiles/makester.mk microk8s-namespace-add --dry-run

    assert_output --regexp 'make _microk8s-namespaces-add-msg _microk8s-namespace-add
### Create namespace "argocd" in MicroK8s ...

microk8s kubectl create namespace "argocd"'

    assert_success
}

# bats test_tags=targets,microk8s-targets,microk8s-namespace-del,dry-run
@test "Microk8s namespace delete with missing K8S_NAMESPACE: dry" {
    MAKESTER__MICROK8S=microk8s\
 run make -f makefiles/makester.mk microk8s-namespace-del --dry-run

    assert_output --regexp '### "K8S_NAMESPACE" undefined
### 
makefiles/microk8s.mk:[0-9]+: \*\*\* ###.  Stop.'

    assert_failure
}
# bats test_tags=targets,microk8s-targets,microk8s-namespace-del,dry-run
@test "Microk8s namespace delete with K8S_NAMESPACE set: dry" {
    MAKESTER__MICROK8S=microk8s K8S_NAMESPACE=argocd\
 run make -f makefiles/makester.mk microk8s-namespace-del --dry-run

    assert_output --regexp 'make _microk8s-namespaces-del-msg _microk8s-namespace-del
### Deleting namespace "argocd" in MicroK8s ...

microk8s kubectl delete namespace "argocd"'

    assert_success
}

# bats test_tags=targets,microk8s-targets,microk8s-reset,dry-run
@test "Microk8s reset to original settings for Darwin: dry" {
    MAKESTER__UNAME=Darwin MAKESTER__LOCAL_IP=192.168.1.1 MAKESTER__MICROK8S=microk8s\
 run make -f makefiles/makester.mk microk8s-reset --dry-run

    assert_output --partial 'make _microk8s-reset-msg _microk8s-reset
### Resetting MicroK8s ...

microk8s reset'

    assert_success
}
# bats test_tags=targets,microk8s-targets,microk8s-reset,dry-run
@test "Microk8s reset to original settings for Linux: dry" {
    MAKESTER__UNAME=Linux MAKESTER__LOCAL_IP=192.168.1.1 MAKESTER__MICROK8S=microk8s\
 run make -f makefiles/makester.mk microk8s-reset --dry-run

    assert_output ''

    assert_success
}

# bats test_tags=targets,microk8s-targets,microk8s-up,dry-run
@test "Microk8s all-in-one starter: dry" {
    MAKESTER__MICROK8S=microk8s MAKESTER__UNAME=Darwin MAKESTER__LOCAL_IP=192.168.1.1\
 run make -f makefiles/makester.mk microk8s-up --dry-run

    assert_output --regexp 'make microk8s-install
make _microk8s-install-msg _microk8s-install
### Installing MicroK8s ...

microk8s install --cpu 2 --mem 4 --channel "1.28/stable" --image 22.04 --disk 50
.*make microk8s-start
### Starting MicroK8s ...

microk8s start
.*make microk8s-wait
### Checking MicroK8s status ...

microk8s status --wait-ready
.*make microk8s-addon-dns
### Enabling the MicroK8s DNS addon ...

microk8s enable dns
### Checking MicroK8s status ...
.*make microk8s-dashboard
/.*/pkill -f "port-forward svc/kubernetes-dashboard"
.*make _microk8s-addon-dashboard
make _microk8s-addon-dashboard-wait
make microk8s-pod-wait
### Enabling the MicroK8s dashboard addon ...

microk8s enable dashboard
### Waiting for Kubernetes dashboard service ...

until \[ \$\(microk8s status --addon dashboard\) = enabled \]; do sleep 2; done
### Waiting for Kubernetes pods in kube-system namespace to be ready ...

until \[ "\$\(microk8s kubectl wait -n kube-system --for=condition=ready pod --all 2>/dev/null \| grep kubernetes-dashboard \| cut -f 2- -d\\ \)" = "condition met" \]; do sleep 2; done
### Creating Makester working directory "'$MAKESTER__WORK_DIR'"

/.*/mkdir -pv '$MAKESTER__WORK_DIR'
### Kubernetes dashboard address forwarded to: https://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:19443
### Kubernetes dashboard log output can be found at '$MAKESTER__WORK_DIR'/microk8s-dashboard.out


.*make _microk8s-dashboard _microk8s-dashboard-backoff
.*make microk8s-dashboard-creds

microk8s kubectl port-forward svc/kubernetes-dashboard -n kube-system 19443:443 --address="0.0.0.0" > '$MAKESTER__WORK_DIR'/microk8s-dashboard.out 2>&1 &
.*/bin/makester backoff [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ 19443 --detail "MicroK8s Kubernetes dashboard"
### Login to the MicroK8s Kubernetes dashboard with following token:

microk8s kubectl create token default'

    assert_success
}

# bats test_tags=targets,microk8s-targets,microk8s-down,dry-run
@test "Microk8s all-in-one stopper for Darwin: dry" {
    MAKESTER__UNAME=Darwin MAKESTER__LOCAL_IP=192.168.1.1 MAKESTER__MICROK8S=microk8s\
 run make -f makefiles/makester.mk microk8s-down --dry-run

    assert_output --regexp 'make microk8s-dashboard-stop
### Closing MicroK8s dashboard port-forward at https://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:19443

.*make _microk8s-reset-dashboard
/.*/pkill -f "port-forward svc/kubernetes-dashboard"
.*make microk8s-reset
.*make _microk8s-reset-msg _microk8s-reset
### Resetting MicroK8s ...

microk8s reset
.*make microk8s-stop
### Stopping MicroK8s ...

microk8s stop
.*make microk8s-uninstall
.*make _microk8s-uninstall-msg _microk8s-uninstall
### Uninstalling MicroK8s ...

microk8s uninstall$'

    assert_success
}
# bats test_tags=targets,microk8s-targets,microk8s-down,dry-run
@test "Microk8s all-in-one stopper for Linux: dry" {
    MAKESTER__UNAME=Linux MAKESTER__LOCAL_IP=192.168.1.1 MAKESTER__MICROK8S=microk8s\
 run make -f makefiles/makester.mk microk8s-down --dry-run

    assert_output --regexp 'make microk8s-dashboard-stop
### Closing MicroK8s dashboard port-forward at https://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:19443

.*make _microk8s-reset-dashboard
/.*/pkill -f "port-forward svc/kubernetes-dashboard"
.*make microk8s-stop
### Stopping MicroK8s ...

microk8s stop
.*make microk8s-uninstall$'

    assert_success
}
