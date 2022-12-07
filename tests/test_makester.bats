# Makester test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --file-filter makester tests
#
# bats file_tags=makester
setup_file() {
    export MAKESTER__WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/makester-XXXXXX")
}
setup() {
    load 'test_helper/common-setup'
    _common_setup
}
teardown_file() {
    MAKESTER__PROJECT_DIR=$PWD make -f makefiles/makester.mk -f makefiles/docker.mk -f makefiles/versioning.mk gitversion-clear
    MAKESTER__WORK_DIR=$MAKESTER__WORK_DIR make -f makefiles/makester.mk makester-work-dir-rm
}

# Makester help.
#
# bats test_tags=help
@test "Makester help" {
    run make -f makefiles/makester.mk makester-help
    assert_output --partial '(makefiles/makester.mk)'
    [ "$status" -eq 0 ]
}

# Environment variable checker.
# bats test_tags=which-var
@test "which-var \"BANANA\" is undefined" {
    MAKESTER__VAR=BANANA MAKESTER__VAR_INFO="Just an error message ..." run make -f makefiles/makester.mk which-var
    assert_output --partial '### Checking if "BANANA" is defined ...
### "BANANA" undefined
### Just an error message ...'
    [ "$status" -eq 2 ]
}
# bats test_tags=which-var
@test "which-var \"MAKESTER__PROJECT_NAME\" is defined" {
    MAKESTER__VAR=MAKESTER__PROJECT_NAME run make -f makefiles/makester.mk which-var
    assert_output --partial '### Checking if "MAKESTER__PROJECT_NAME" is defined ...'
    [ "$status" -eq 0 ]
}
# bats test_tags=which-var
@test "which-var \"MAKESTER__WORK_DIR\" is defined" {
    MAKESTER__VAR=MAKESTER__WORK_DIR run make -f makefiles/makester.mk which-var
    assert_output --partial '### Checking if "MAKESTER__WORK_DIR" is defined ...'
    [ "$status" -eq 0 ]
}

# Makester variables.
#
# MAKESTER__PRIMED
# bats test_tags=variables,makester-variables,MAKESTER__PRIMED
@test "MAKESTER__PRIMED should be set when calling makester.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PRIMED
    assert_output 'MAKESTER__PRIMED=true'
    [ "$status" -eq 0 ]
}

# MAKESTER__LOCAL_IP
# bats test_tags=variables,makester-variables,MAKESTER__LOCAL_IP
@test "Override MAKESTER__LOCAL_IP override" {
    MAKESTER__LOCAL_IP=127.0.0.1 run make -f makefiles/makester.mk print-MAKESTER__LOCAL_IP
    assert_output 'MAKESTER__LOCAL_IP=127.0.0.1'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,makester-variables,MAKESTER__RELEASE_VERSION
@test "MAKESTER__RELEASE_VERSION defaults to HASH" {
    run make -f makefiles/makester.mk print-MAKESTER__RELEASE_VERSION
    assert_output 'MAKESTER__RELEASE_VERSION=<undefined>'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__RELEASE_VERSION
@test "MAKESTER__RELEASE_VERSION override" {
    MAKESTER__RELEASE_VERSION=override run make -f makefiles/makester.mk print-MAKESTER__RELEASE_VERSION
    assert_output --regexp '^MAKESTER__RELEASE_VERSION=override$'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,makester-variables,MAKESTER__K8S_MANIFESTS
@test "MAKESTER__K8S_MANIFESTS should be set when calling makester.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__K8S_MANIFESTS
    assert_output --regexp 'MAKESTER__K8S_MANIFESTS=/.*/makester-[a-zA-Z0-9]{4,8}/k8s/manifests'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__K8S_MANIFESTS
@test "MAKESTER__K8S_MANIFESTS override" {
    MAKESTER__K8S_MANIFESTS=dummy run make -f makefiles/makester.mk print-MAKESTER__K8S_MANIFESTS
    assert_output --regexp 'MAKESTER__K8S_MANIFESTS=dummy'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,makester-variables,MAKESTER__PROJECT_DIR
@test "MAKESTER__PROJECT_DIR should be set when calling makester.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PROJECT_DIR
    assert_output --regexp "MAKESTER__PROJECT_DIR=$PWD"
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__PROJECT_DIR
@test "MAKESTER__PROJECT_DIR override" {
    MAKESTER__PROJECT_DIR=dummy run make -f makefiles/makester.mk print-MAKESTER__PROJECT_DIR
    assert_output --regexp 'MAKESTER__PROJECT_DIR=dummy'
    [ "$status" -eq 0 ]
}

# Executable checker.
# bats test_tags=check-exe
@test "check-exe rule for \"GIT\" finds the executable" {
    run make -f makefiles/makester.mk print-GIT
    assert_output --regexp 'GIT=.*/git'
    [ "$status" -eq 0 ]
}
