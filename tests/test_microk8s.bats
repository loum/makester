# MicroK8s test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags microk8s tests
#
# bats file_tags=microk8s
setup() {
  load 'test_helper/common-setup'
  _common_setup
}

# MicroK8s include dependencies.
#
# Makester.
# bats test_tags=microk8s-dependencies
@test "Check if Makester is primed: false" {
    run make -f makefiles/microk8s.mk
    assert_output --partial '### Add the following include statement to your Makefile
include makester/makefiles/makester.mk'
    [ "$status" -eq 2 ]
}
# bats test_tags=microk8s-dependencies
@test "Check if Makester is primed: true" {
    run make -f makefiles/makester.mk microk8s-help
    assert_output --partial '(makefiles/microk8s.mk)'
    [ "$status" -eq 0 ]
}

# MicroK8s variables.
#
# bats test_tags=variables,microk8s-variables,MAKESTER__MICROK8S_EXE_NAME
@test "MAKESTER__MICROK8S_EXE_NAME default should be set when calling k8s.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__MICROK8S_EXE_NAME
    assert_output 'MAKESTER__MICROK8S_EXE_NAME=microk8s'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,microk8s-variables,MAKESTER__MICROK8S_EXE_NAME
@test "MAKESTER__MICROK8S_EXE_NAME override" {
    MAKESTER__MICROK8S_EXE_NAME=/usr/local/bin/microk8s\
 run make -f makefiles/makester.mk print-MAKESTER__MICROK8S_EXE_NAME
    assert_output 'MAKESTER__MICROK8S_EXE_NAME=/usr/local/bin/microk8s'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,microk8s-variables,MAKESTER__MICROK8S_EXE_INSTALL
@test "MAKESTER__MICROK8S_EXE_INSTALL default should be set when calling k8s.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__MICROK8S_EXE_INSTALL
    assert_output 'MAKESTER__MICROK8S_EXE_INSTALL=https://microk8s.io/docs/getting-started'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,microk8s-variables,MAKESTER__MICROK8S_EXE_INSTALL
@test "MAKESTER__MICROK8S_EXE_INSTALL override" {
    MAKESTER__MICROK8S_EXE_INSTALL=http://localhost:8000\
 run make -f makefiles/makester.mk print-MAKESTER__MICROK8S_EXE_INSTALL
    assert_output 'MAKESTER__MICROK8S_EXE_INSTALL=http://localhost:8000'
    [ "$status" -eq 0 ]
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
    [ "$status" -eq 2 ]
}
# bats test_tags=targets,microk8s-targets,microk8s-status,dry-run
@test "Microk8s status: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-status --dry-run
    assert_output '### Checking MicroK8s status ...
microk8s status'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,microk8s-targets,microk8s-install,dry-run
@test "Microk8s install: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-install --dry-run
    assert_output '### Installing MicroK8s ...
microk8s install'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,microk8s-targets,microk8s-uninstall,dry-run
@test "Microk8s uninstall: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-uninstall --dry-run
    assert_output '### Uninstalling MicroK8s ...
microk8s uninstall'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,microk8s-targets,microk8s-wait,dry-run
@test "Microk8s status and wait for Kubernetes services: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-wait --dry-run
    assert_output '### Checking MicroK8s status ...
microk8s status --wait-ready'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,microk8s-targets,microk8s-start,dry-run
@test "Microk8s start: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-start --dry-run
    assert_output --regexp '^### Starting MicroK8s ...
microk8s start
.*make microk8s-wait
### Checking MicroK8s status ...
microk8s status --wait-ready$'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,microk8s-targets,microk8s-dashboard-proxy,dry-run
@test "Microk8s dashboard proxy: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-dashboard-proxy --dry-run
    assert_output '### MicroK8s CLI-blocking Kubernetes dashboard...
microk8s dashboard-proxy'
    [ "$status" -eq 0 ]
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
until \[ "\$\(microk8s kubectl wait -n kube-system --for=condition=ready pod --all 2>/dev/null | grep kubernetes-dashboard | cut -f 2- -d\\ \)" = "condition met" \]; do sleep 2; done'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,microk8s-targets,microk8s-addon-dns,dry-run
@test "Microk8s addon for dns: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-addon-dns --dry-run
    assert_output '### Enabling the MicroK8s DNS addon ...
microk8s enable dns
### Checking MicroK8s status ...'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,microk8s-targets,microk8s-namespaces,dry-run
@test "Microk8s namespaces: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-namespaces --dry-run
    assert_output '### Display all active namespaces in MicroK8s ...
microk8s kubectl get namespace'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,microk8s-targets,microk8s-reset,dry-run
@test "Microk8s reset to original settings: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-reset --dry-run
    assert_output '### Resetting MicroK8s ...
microk8s reset'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,microk8s-targets,microk8s-up,dry-run
@test "Microk8s all-in-one starter: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-up --dry-run
    assert_output --regexp 'make microk8s-install
### Installing MicroK8s ...
microk8s install
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
/.*/pkill -f "kubectl port-forward svc/kubernetes-dashboard"
.*make _microk8s-addon-dashboard
### Enabling the MicroK8s dashboard addon ...
microk8s enable dashboard
.*make _microk8s-addon-dashboard-wait
### Waiting for Kubernetes dashboard service ...
until \[ \$\(microk8s status --addon dashboard\) = enabled \]; do sleep 2; done
.*make microk8s-pod-wait
### Waiting for Kubernetes pods in kube-system namespace to be ready ...
until \[ "\$\(microk8s kubectl wait -n kube-system --for=condition=ready pod --all 2>/dev/null | grep kubernetes-dashboard | cut -f 2- -d\\ \)" = "condition met" \]; do sleep 2; done
### Kubernetes dashboard address forwarded to: https://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:19443
### Kubernetes dashboard log output can be found at /.*/.makester/microk8s-dashboard.out
.*make _microk8s-dashboard _microk8s-dashboard-backoff
microk8s kubectl port-forward svc/kubernetes-dashboard -n kube-system 19443:443 --address="0.0.0.0" > /.*/.makester/microk8s-dashboard.out 2>&1 &
venv/bin/makester backoff [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ 19443 --detail "MicroK8s Kubernetes dashboard"
.*make microk8s-dashboard-creds
### Login to the MicroK8s Kubernetes dashboard with following token:
microk8s kubectl get secret -n kube-system microk8s-dashboard-token -o jsonpath="\{.data.token\}" | base64 -d; echo$'

    [ "$status" -eq 0 ]
}

# bats test_tags=targets,microk8s-targets,microk8s-down,dry-run
@test "Microk8s all-in-one stopper: dry" {
    MAKESTER__MICROK8S=microk8s run make -f makefiles/makester.mk microk8s-down --dry-run
    assert_output --regexp 'make microk8s-dashboard-stop
### Closing MicroK8s dashboard port-forward at https://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:19443
.*make _microk8s-reset-dashboard
/.*/pkill -f "kubectl port-forward svc/kubernetes-dashboard"
.*make microk8s-reset
### Resetting MicroK8s ...
microk8s reset
.*make microk8s-stop
### Stopping MicroK8s ...
microk8s stop
.*make microk8s-uninstall
### Uninstalling MicroK8s ...
microk8s uninstall$'
    [ "$status" -eq 0 ]
}
