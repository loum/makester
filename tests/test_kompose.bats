# Kompose test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags kompose tests
#
# bats file_tags=kompose
setup_file() {
    export MAKESTER__WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/makester-XXXXXX")
}
setup() {
  load 'test_helper/common-setup'
  _common_setup
}
teardown_file() {
    make -f makefiles/makester.mk kompose-clear
    MAKESTER__WORK_DIR=$MAKESTER__WORK_DIR make -f makefiles/makester.mk makester-work-dir-rm
}

# Kompose include dependencies.
#
# Makester.
# bats test_tags=kompose-dependencies
@test "Check if Makester is primed: false" {
    run make -f makefiles/kompose.mk

    assert_output --partial '### Add the following include statement to your Makefile
include makester/makefiles/makester.mk'

    assert_failure
}
# bats test_tags=kompose-dependencies
@test "Check if Makester is primed: true" {
    run make -f makefiles/makester.mk kompose-help

    assert_output --partial '(makefiles/kompose.mk)'

    assert_success
}

# Kompose variables.
#
# MAKESTER__COMPOSE_K8S_EPHEMERAL
# bats test_tags=variables,kompose-variables,MAKESTER__COMPOSE_K8S_EPHEMERAL
@test "MAKESTER__COMPOSE_K8S_EPHEMERAL default should be set when calling kompose.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__COMPOSE_K8S_EPHEMERAL

    assert_output 'MAKESTER__COMPOSE_K8S_EPHEMERAL=docker-compose.yml'

    assert_success
}
# bats test_tags=variables,kompose-variables,MAKESTER__COMPOSE_K8S_EPHEMERAL
@test "MAKESTER__COMPOSE_K8S_EPHEMERAL override" {
    MAKESTER__COMPOSE_K8S_EPHEMERAL=sample/docker-compose.yml\
 run make -f makefiles/makester.mk print-MAKESTER__COMPOSE_K8S_EPHEMERAL

    assert_output 'MAKESTER__COMPOSE_K8S_EPHEMERAL=sample/docker-compose.yml'

    assert_success
}

# bats test_tags=variables,kompose-variables,MAKESTER__KOMPOSE_EXE_NAME
@test "MAKESTER__KOMPOSE_EXE_NAME default should be set when calling k8s.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__KOMPOSE_EXE_NAME

    assert_output 'MAKESTER__KOMPOSE_EXE_NAME=kompose'

    assert_success
}
# bats test_tags=variables,kompose-variables,MAKESTER__KOMPOSE_EXE_KOMPOSE
@test "MAKESTER__KOMPOSE_EXE_KOMPOSE override" {
    MAKESTER__KOMPOSE_EXE_KOMPOSE=dummy \
 run make -f makefiles/makester.mk print-MAKESTER__KOMPOSE_EXE_KOMPOSE

    assert_output 'MAKESTER__KOMPOSE_EXE_KOMPOSE=dummy'

    assert_success
}

# bats test_tags=variables,kompose-variables,MAKESTER__KOMPOSE_EXE_INSTALL
@test "MAKESTER__KOMPOSE_EXE_INSTALL default should be set when calling k8s.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__KOMPOSE_EXE_INSTALL

    assert_output 'MAKESTER__KOMPOSE_EXE_INSTALL=https://kompose.io/installation/'

    assert_success
}
# bats test_tags=variables,kompose-variables,MAKESTER__KOMPOSE_EXE_INSTALL
@test "MAKESTER__KOMPOSE_EXE_INSTALL override" {
    MAKESTER__KOMPOSE_EXE_INSTALL=http://localhost:8000 \
 run make -f makefiles/makester.mk print-MAKESTER__KOMPOSE_EXE_INSTALL

    assert_output 'MAKESTER__KOMPOSE_EXE_INSTALL=http://localhost:8000'

    assert_success
}

# Targets.
#
# bats test_tags=targets,kompose-targets,kompose,dry-run
@test "Convert compose to k8s manifest: undefined MAKESTER__KOMPOSE_EXE_NAME" {
    MAKESTER__KOMPOSE_EXE_NAME=banana MAKESTER__COMPOSE_K8S_EPHEMERAL=sample/docker-compose.yml\
 run make -f makefiles/makester.mk kompose --dry-run

    assert_output --regexp '### MAKESTER__KOMPOSE: <undefined>
### MAKESTER__KOMPOSE_EXE_NAME set as "banana"
### "banana" not found
### Install notes: https://kompose.io/installation/
makefiles/kompose.mk:[0-9]{1,4}: \*\*\* ###.  Stop.'

    assert_failure
}
