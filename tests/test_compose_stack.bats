# Test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --file-filter compose-stack tests
#
# bats file_tags=compose-stack
setup_file() {
    export SAMPLE_COMPOSE_PORT=$(shuf -i 29000-29999 -n 1)
    MAKESTER__DOCKER=docker MAKESTER__PROJECT_NAME=makester MAKESTER__COMPOSE_FILES="-f sample/docker-compose.yml"\
 run make -f makefiles/makester.mk -f makefiles/compose.mk compose-up
}
setup() {
    load 'test_helper/common-setup'
    _common_setup
}
teardown_file() {
    MAKESTER__DOCKER=docker MAKESTER__PROJECT_NAME=makester MAKESTER__COMPOSE_FILES="-f sample/docker-compose.yml"\
 run make -f makefiles/makester.mk -f makefiles/compose.mk compose-down
}

# Compose config
# 
# bats test_tags=compose-config
@test "Sample Compose stack config output" {
    MAKESTER__DOCKER=docker MAKESTER__PROJECT_NAME=makester MAKESTER__COMPOSE_FILES="-f sample/docker-compose.yml"\
 run make -f makefiles/makester.mk -f makefiles/compose.mk compose-config
    assert_output "name: makester
services:
  redis:
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
    [ "$status" -eq 0 ]
}

# Compose stack.
#
# bats test_tags=compose-stack-status
@test "Sample Compose stack HTTP response" {
    result="$(wget -qO- --server-response localhost:$SAMPLE_COMPOSE_PORT 2>&1 | awk '/^  HTTP/{print $2}')"
    [ "$result" -eq 200 ]
}

# Targets.
# bats test_tags=targets,compose-ls
@test "Sample Compose application listing" {
    MAKESTER__PROJECT_NAME=makester\
 run make -f makefiles/makester.mk -f makefiles/docker.mk -f makefiles/compose.mk compose-ls
    assert_output --regexp 'NAME                STATUS              CONFIG FILES
makester            running\(1\)          .*/makester/sample/docker-compose.yml'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,compose-ps
@test "Sample Compose container listing" {
    MAKESTER__PROJECT_NAME=makester\
 run make -f makefiles/makester.mk -f makefiles/docker.mk -f makefiles/compose.mk compose-ps
    assert_output --partial "\
NAME                COMMAND                  SERVICE             STATUS              PORTS
makester-example    \"/docker-entrypoint.…\"   redis               running             0.0.0.0:$SAMPLE_COMPOSE_PORT->80/tcp"
    [ "$status" -eq 0 ]
}
