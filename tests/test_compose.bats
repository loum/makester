# Docker compose Test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags compose tests
#
# bats file_tags=compose
setup() {
    load 'test_helper/common-setup'
    _common_setup
}

# Makester include dependencies.
#
# Makester.
# bats test_tags=compose-dependencies
@test "Check docker executable dependency without makester.mk" {
    run make -f makefiles/compose.mk

    assert_output --partial '### Add the following include statement to your Makefile
include makester/makefiles/makester.mk'

    assert_failure
}
# bats test_tags=compose-dependencies
@test "Check docker executable dependency with makester.mk" {
    run make -f makefiles/makester.mk compose-help

    assert_output --partial '(makefiles/compose.mk)'

    assert_success
}

# Compose variables.
#
# MAKESTER__COMPOSE_FILES
# bats test_tags=variables,compose-variables,MAKESTER__COMPOSE_FILES
@test "MAKESTER__COMPOSE_FILES default should be set when calling compose.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__COMPOSE_FILES

    assert_output 'MAKESTER__COMPOSE_FILES=-f docker-compose.yml'

    assert_success
}
# bats test_tags=variables,compose-variables,MAKESTER__COMPOSE_FILES
@test "MAKESTER__COMPOSE_FILES override" {
    MAKESTER__COMPOSE_FILES="-f sample/docker-compose.yml"\
 run make -f makefiles/makester.mk print-MAKESTER__COMPOSE_FILES

    assert_output 'MAKESTER__COMPOSE_FILES=-f sample/docker-compose.yml'

    assert_success
}

# MAKESTER__COMPOSE_RUN_CMD
# bats test_tags=variables,compose-variables,MAKESTER__COMPOSE_RUN_CMD
@test "MAKESTER__COMPOSE_RUN_CMD default should be set when calling compose.mk" {
    MAKESTER__PROJECT_NAME=makester MAKESTER__DOCKER=docker MAKESTER__LOCAL_REGISTRY_RUNNING=\
 run make -f makefiles/makester.mk print-MAKESTER__COMPOSE_RUN_CMD

    assert_output --regexp "MAKESTER__COMPOSE_RUN_CMD=\
SERVICE_NAME=makester HASH=[0-9a-z]{7} docker compose --project-name makester -f docker-compose.yml version"

    assert_success
}

# Targets.
# bats test_tags=targets,compose-targets,compose-version
@test "Compose version" {
    MAKESTER__PROJECT_NAME=makester run make -f makefiles/makester.mk compose-version

    assert_output --regexp '^Docker Compose version [v]{0,1}[0-9]{1}\.[0-9]{1,2}\.[0-9]{1,3}'

    assert_success
}
