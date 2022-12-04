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
    make -f makefiles/makester.mk -f makefiles/kompose.mk kompose-clear
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
    [ "$status" -eq 2 ]
}
# bats test_tags=kompose-dependencies
@test "Check if Makester is primed: true" {
    run make -f makefiles/makester.mk -f makefiles/kompose.mk kompose-help
    assert_output --partial '(makefiles/kompose.mk)'
    [ "$status" -eq 0 ]
}

# Kompose variables.
#
# MAKESTER__COMPOSE_K8S_EPHEMERAL
# bats test_tags=variables,kompose-variables,MAKESTER__COMPOSE_K8S_EPHEMERAL
@test "MAKESTER__COMPOSE_K8S_EPHEMERAL default should be set when calling kompose.mk" {
    run make -f makefiles/makester.mk -f makefiles/kompose.mk print-MAKESTER__COMPOSE_K8S_EPHEMERAL
    assert_output 'MAKESTER__COMPOSE_K8S_EPHEMERAL=docker-compose.yml'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,kompose-variables,MAKESTER__COMPOSE_K8S_EPHEMERAL
@test "MAKESTER__COMPOSE_K8S_EPHEMERAL override" {
    MAKESTER__COMPOSE_K8S_EPHEMERAL=sample/docker-compose.yml\
 run make -f makefiles/makester.mk -f makefiles/kompose.mk print-MAKESTER__COMPOSE_K8S_EPHEMERAL
    assert_output 'MAKESTER__COMPOSE_K8S_EPHEMERAL=sample/docker-compose.yml'
    [ "$status" -eq 0 ]
}

# Targets.
# bats test_tags=targets,kompose-targets,kompose,dry-run
@test "Convert compose to k8s manifest" {
    MAKESTER__KOMPOSE=kompose MAKESTER__COMPOSE_K8S_EPHEMERAL=sample/docker-compose.yml\
 run make -f makefiles/makester.mk -f makefiles/kompose.mk kompose --dry-run
    assert_output --regexp 'kompose convert --file sample/docker-compose.yml --out /.*/makester-[a-zA-Z0-9]{4,8}/k8s/manifests'
    [ "$status" -eq 0 ]
}
