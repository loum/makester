# K8s test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags k8s tests
#
# bats file_tags=k8s
setup() {
  load 'test_helper/common-setup'
  _common_setup
}

# K8s include dependencies.
#
# Makester.
# bats test_tags=k8s-dependencies
@test "Check if Makester is primed: false" {
    run make -f makefiles/k8s.mk

    assert_output --partial '### Add the following include statement to your Makefile
include makester/makefiles/makester.mk'

    assert_failure
}
# bats test_tags=k8s-dependencies
@test "Check if Makester is primed: true" {
    run make -f makefiles/makester.mk k8s-help

    assert_output --partial '(makefiles/k8s.mk)'

    assert_success
}

# Minikube variables.
#
# bats test_tags=variables,minikube-variables,MAKESTER__MINIKUBE_EXE_NAME
@test "MAKESTER__MINIKUBE_EXE_NAME default should be set when calling k8s.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__MINIKUBE_EXE_NAME

    assert_output 'MAKESTER__MINIKUBE_EXE_NAME=minikube'

    assert_success
}
# bats test_tags=variables,minikube-variables,MAKESTER__MINIKUBE_EXE_NAME
@test "MAKESTER__MINIKUBE_EXE_NAME override" {
    MAKESTER__MINIKUBE_EXE_NAME=/usr/local/bin/minikube\
 run make -f makefiles/makester.mk print-MAKESTER__MINIKUBE_EXE_NAME

    assert_output 'MAKESTER__MINIKUBE_EXE_NAME=/usr/local/bin/minikube'

    assert_success
}

# bats test_tags=variables,minikube-variables,MAKESTER__MINIKUBE_EXE_INSTALL
@test "MAKESTER__MINIKUBE_EXE_INSTALL default should be set when calling k8s.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__MINIKUBE_EXE_INSTALL

    assert_output 'MAKESTER__MINIKUBE_EXE_INSTALL=https://kubernetes.io/docs/tasks/tools/#minikube'

    assert_success
}
# bats test_tags=variables,minikube-variables,MAKESTER__MINIKUBE_EXE_INSTALL
@test "MAKESTER__MINIKUBE_EXE_INSTALL override" {
    MAKESTER__MINIKUBE_EXE_INSTALL=http://localhost:8000\
 run make -f makefiles/makester.mk print-MAKESTER__MINIKUBE_EXE_INSTALL

    assert_output 'MAKESTER__MINIKUBE_EXE_INSTALL=http://localhost:8000'

    assert_success
}

# bats test_tags=variables,kubectl-variables,MAKESTER__KUBECTL_EXE_NAME
@test "MAKESTER__KUBECTL_EXE_NAME default should be set when calling k8s.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__KUBECTL_EXE_NAME

    assert_output 'MAKESTER__KUBECTL_EXE_NAME=kubectl'

    assert_success
}
# bats test_tags=variables,kubectl-variables,MAKESTER__KUBECTL_EXE_NAME
@test "MAKESTER__KUBECTL_EXE_NAME override" {
    MAKESTER__KUBECTL_EXE_NAME=/usr/local/bin/kubectl\
 run make -f makefiles/makester.mk print-MAKESTER__KUBECTL_EXE_NAME

    assert_output 'MAKESTER__KUBECTL_EXE_NAME=/usr/local/bin/kubectl'

    assert_success
}

# bats test_tags=variables,kubectl-variables,MAKESTER__KUBECTL_EXE_INSTALL
@test "MAKESTER__KUBECTL_EXE_INSTALL default should be set when calling k8s.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__KUBECTL_EXE_INSTALL

    assert_output 'MAKESTER__KUBECTL_EXE_INSTALL=https://kubernetes.io/docs/tasks/tools/'

    assert_success
}
# bats test_tags=variables,kubectl-variables,MAKESTER__KUBECTL_EXE_INSTALL
@test "MAKESTER__KUBECTL_EXE_INSTALL override" {
    MAKESTER__KUBECTL_EXE_INSTALL=http://localhost:8000\
 run make -f makefiles/makester.mk print-MAKESTER__KUBECTL_EXE_INSTALL

    assert_output 'MAKESTER__KUBECTL_EXE_INSTALL=http://localhost:8000'

    assert_success
}

# Targets.
#
# bats test_tags=targets,minikube-targets,mk-status,dry-run
@test "Minikube status: undefined MAKESTER__MINKUBE_EXE_NAME" {
    MAKESTER__MINIKUBE_EXE_NAME=banana run make -f makefiles/makester.mk mk-status --dry-run

    assert_output --regexp '### MAKESTER__MINIKUBE: <undefined>
### MAKESTER__MINIKUBE_EXE_NAME set as "banana"
### "banana" not found
### Install notes: https://kubernetes.io/docs/tasks/tools/#minikube
makefiles/k8s.mk:[0-9]{1,4}: \*\*\* ###.  Stop.'

    assert_failure
}

# bats test_tags=targets,kubectl-targets,kubectl-context,dry-run
@test "Kubectl config get contexts: undefined MAKESTER__KUBECTL_EXE_NAME" {
    MAKESTER__KUBECTL_EXE_NAME=banana run make -f makefiles/makester.mk kube-context --dry-run

    assert_output --regexp '### MAKESTER__KUBECTL: <undefined>
### MAKESTER__KUBECTL_EXE_NAME set as "banana"
### "banana" not found
### Install notes: https://kubernetes.io/docs/tasks/tools/
makefiles/k8s.mk:[0-9]{1,4}: \*\*\* ###.  Stop.'

    assert_failure
}
