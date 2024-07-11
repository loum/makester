# Docker compose stack Test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags compose-stack tests
#
# bats file_tags=compose-stack
setup_file() {
    export SAMPLE_COMPOSE_PORT=$(shuf -i 29000-29999 -n 1)
    MAKESTER__DOCKER=docker MAKESTER__PROJECT_NAME=makester MAKESTER__COMPOSE_FILES="-f resources/sample/docker-compose.yml"\
 run make -f makefiles/makester.mk compose-up
}
setup() {
    load 'test_helper/common-setup'
    _common_setup
}
teardown_file() {
    MAKESTER__DOCKER=docker MAKESTER__PROJECT_NAME=makester MAKESTER__COMPOSE_FILES="-f resources/sample/docker-compose.yml"\
 run make -f makefiles/makester.mk compose-down
}

# Targets
# 
# bats test_tags=targets,compose-stack-targets,compose-config
@test "Sample Compose stack config output" {
    MAKESTER__DOCKER=docker MAKESTER__PROJECT_NAME=makester MAKESTER__COMPOSE_FILES="-f resources/sample/docker-compose.yml"\
 run make -f makefiles/makester.mk compose-config

    assert_output "name: makester
services:
  demo:
    container_name: makester-example
    image: nginxdemos/hello
    networks:
      default: null
    ports:
      - mode: ingress
        target: 80
        published: \"$SAMPLE_COMPOSE_PORT\"
        protocol: tcp
networks:
  default:
    name: makester_default"

    assert_success
}

# bats test_tags=targets,compose-stack-targets,compose-stack-status
@test "Sample Compose stack HTTP response" {
    run echo "$(wget -qO- --server-response localhost:$SAMPLE_COMPOSE_PORT 2>&1 | awk '/^  HTTP/{print $2}')"

    assert_output 200
}

# bats test_tags=targets,compose-stack-targets,compose-ls
@test "Sample Compose application listing" {
    MAKESTER__PROJECT_NAME=makester\
 run make -f makefiles/makester.mk compose-ls

    assert_output --regexp "makester[ ]+running"

    assert_success
}

# bats test_tags=targets,compose-stack-targets,compose-ps
@test "Sample Compose container listing" {
    MAKESTER__PROJECT_NAME=makester MAKESTER__COMPOSE_FILES="-f resources/sample/docker-compose.yml"\
 run make -f makefiles/makester.mk compose-ps

    assert_success
}
