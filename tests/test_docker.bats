# Docker test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags docker tests
#
# bats file_tags=docker
setup() {
    load 'test_helper/common-setup'
    _common_setup
}

# Docker include dependencies.
#
# Makester.
# bats test_tags=docker-dependencies
@test "Check if Makester is primed: false" {
    run make -f makefiles/docker.mk
    assert_output --partial '### Add the following include statement to your Makefile
include makester/makefiles/makester.mk'
    [ "$status" -eq 2 ]
}
# bats test_tags=docker-dependencies
@test "Check if Makester is primed: true" {
    run make -f makefiles/makester.mk docker-help
    assert_output --partial '(makefiles/docker.mk)'
    [ "$status" -eq 0 ]
}

# Docker variables.
#
# bats test_tags=variables,docker-variables,MAKESTER__CONTAINER_NAME
@test "MAKESTER__CONTAINER_NAME default should be set when calling docker.mk" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk print-MAKESTER__CONTAINER_NAME
    assert_output 'MAKESTER__CONTAINER_NAME=my-container'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,docker-variables,MAKESTER__CONTAINER_NAME
@test "MAKESTER__CONTAINER_NAME override" {
    MAKESTER__DOCKER=docker MAKESTER__CONTAINER_NAME=override\
 run make -f makefiles/makester.mk print-MAKESTER__CONTAINER_NAME
    assert_output 'MAKESTER__CONTAINER_NAME=override'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,docker-variables,MAKESTER__IMAGE_TARGET_TAG
@test "MAKESTER__IMAGE_TARGET_TAG default should be set to HASH when calling docker.mk" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk print-MAKESTER__IMAGE_TARGET_TAG
    assert_output --regexp '^MAKESTER__IMAGE_TARGET_TAG=[0-9a-z]{7}$'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,docker-variables,MAKESTER__IMAGE_TARGET_TAG
@test "MAKESTER__IMAGE_TARGET_TAG override" {
    MAKESTER__DOCKER=docker MAKESTER__IMAGE_TARGET_TAG=override\
 run make -f makefiles/makester.mk print-MAKESTER__IMAGE_TARGET_TAG
    assert_output 'MAKESTER__IMAGE_TARGET_TAG=override'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,docker-variables,MAKESTER__RUN_COMMAND
@test "MAKESTER__RUN_COMMAND default should be set when calling docker.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__RUN_COMMAND
    assert_output --regexp '^MAKESTER__RUN_COMMAND=.*/docker run --rm --name my-container makefiles:[0-9a-z]{7}$'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,docker-variables,MAKESTER__RUN_COMMAND
@test "MAKESTER__RUN_COMMAND override" {
    MAKESTER__RUN_COMMAND="\$(MAKESTER__DOCKER) run hello-world"\
 run make -f makefiles/makester.mk print-MAKESTER__RUN_COMMAND
    assert_output --regexp 'MAKESTER__RUN_COMMAND=.*/docker run hello-world'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,docker-variables,MAKESTER__BUILD_COMMAND
@test "MAKESTER__BUILD_COMMAND default should be set when calling docker.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__BUILD_COMMAND
    assert_output --regexp '^MAKESTER__BUILD_COMMAND=-t makefiles:[0-9a-z]{7} \.$'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,docker-variables,MAKESTER__BUILD_COMMAND
@test "MAKESTER__BUILD_COMMAND override" {
    MAKESTER__BUILD_COMMAND="--no-cache -t \$(MAKESTER__IMAGE_TAG_ALIAS) ."\
 run make -f makefiles/makester.mk print-MAKESTER__BUILD_COMMAND
    assert_output --regexp '^MAKESTER__BUILD_COMMAND=--no-cache -t makefiles:[0-9a-z]{7} \.$'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,docker-variables,MAKESTER__IMAGE_TAG_ALIAS
@test "MAKESTER__IMAGE_TAG_ALIAS default should be set when calling docker.mk" {
    MAKESTER__PROJECT_NAME=makester\
 run make -f makefiles/makester.mk print-MAKESTER__IMAGE_TAG_ALIAS
    assert_output --regexp '^MAKESTER__IMAGE_TAG_ALIAS=makester:[0-9a-z]{7}$'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,docker-variables,MAKESTER__IMAGE_TAG_ALIAS
@test "MAKESTER__IMAGE_TAG_ALIAS override" {
    MAKESTER__PROJECT_NAME=makester MAKESTER__IMAGE_TARGET_TAG="\$(MAKESTER__VERSION)-\$(MAKESTER__RELEASE_NUMBER)"\
 run make -f makefiles/makester.mk print-MAKESTER__IMAGE_TAG_ALIAS
    assert_output 'MAKESTER__IMAGE_TAG_ALIAS=makester:0.0.0-1'
    [ "$status" -eq 0 ]
}

# Targets.
#
# bats test_tags=targets,docker-targets,image,image-tag,dry-run
@test "Default Docker image tag: dry" {
    MAKESTER__PROJECT_NAME=makester MAKESTER__DOCKER=docker\
 run make -f makefiles/makester.mk image-tag --dry-run
    assert_output --regexp '^docker tag  makester:[0-9a-z]{7}$'
    [ "$status" -eq 0 ]
}
# bats test_tags=targets,docker-targets,image,image-tag,dry-run
@test "Default Docker image tag override: dry" {
    MAKESTER__PROJECT_NAME=makester\
 MAKESTER__DOCKER=docker MAKESTER__IMAGE_TARGET_TAG="\$(MAKESTER__VERSION)-\$(MAKESTER__RELEASE_NUMBER)"\
 run make -f makefiles/makester.mk image-tag --dry-run
    assert_output 'docker tag  makester:0.0.0-1'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,docker-targets,image,image-buildx,dry-run
@test "Default Docker image buildx: dry" {
    MAKESTER__PROJECT_NAME=makester MAKESTER__DOCKER=docker\
 run make -f makefiles/makester.mk image-buildx --dry-run
    assert_output --regexp 'docker buildx build -t makester:[0-9a-z]{7} .'
    [ "$status" -eq 0 ]
}
# bats test_tags=targets,docker-targets,image,image-buildx,dry-run
@test "Docker image buildx overridden tag: dry" {
    MAKESTER__PROJECT_NAME=makester\
 MAKESTER__DOCKER=docker MAKESTER__IMAGE_TARGET_TAG="\$(MAKESTER__VERSION)-\$(MAKESTER__RELEASE_NUMBER)"\
 run make -f makefiles/makester.mk image-buildx --dry-run
    assert_output 'docker buildx build -t makester:0.0.0-1 .'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,docker-targets,container,container-run,dry-run
@test "Container run with container-run: dry" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk container-run --dry-run
    assert_output --regexp 'docker run --rm --name my-container makefiles:[0-9a-z]{7}'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,docker-targets,container,container-stop,dry-run
@test "Container stop with container-stop: dry" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk container-stop --dry-run
    assert_output --regexp 'docker stop my-container'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,docker-targets,container,container-root,dry-run
@test "Container root shell with container-root: dry" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk container-root --dry-run
    assert_output 'docker exec -ti -u 0 my-container sh || true'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,docker-targets,container,container-sh,dry-run
@test "Container shell with container-shell: dry" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk container-sh --dry-run
    assert_output 'docker exec -ti my-container sh || true'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,docker-targets,container,container-bash,dry-run
@test "Container bash with container-bash: dry" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk container-bash --dry-run
    assert_output 'docker exec -ti my-container bash || true'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,docker-targets,container,container-logs,dry-run
@test "Container bash with container-logs: dry" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk container-logs --dry-run
    assert_output 'docker logs --follow my-container'
    [ "$status" -eq 0 ]
}

# Symbol deprecation.
#
# bats test_tags=deprecated,dry-run
@test "Warning for deprecated symbol target search-image" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk search-image --dry-run
    assert_output '### "search-image" will be deprecated in Makester: 0.3.0
### Replace "search-image" with "image-search"
docker images "makefiles*"'
    [ "$status" -eq 0 ]
}

# bats test_tags=deprecated,dry-run
@test "Warning for deprecated symbol target build-image" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk build-image --dry-run
    assert_output --regexp '### "build-image" will be deprecated in Makester: 0.3.0
### Replace "build-image" with "image-build"
docker build -t makefiles:[0-9a-z]{7}'
    [ "$status" -eq 0 ]
}

# bats test_tags=deprecated,dry-run
@test "Warning for deprecated symbol target tag-image" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk tag-image --dry-run
    assert_output --regexp '### "tag-image" will be deprecated in Makester: 0.3.0
### Replace "tag-image" with "image-tag"
docker tag .* makefiles:[0-9a-z]{7}'
    [ "$status" -eq 0 ]
}

# bats test_tags=deprecated,dry-run
@test "Warning for deprecated symbol target run" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk run --dry-run
    assert_output --regexp '### "run" will be deprecated in Makester: 0.3.0
### Replace "run" with "container-run"
docker run --rm --name my-container makefiles:[0-9a-z]{7}'
    [ "$status" -eq 0 ]
}

# bats test_tags=deprecated,dry-run
@test "Warning for deprecated symbol target stop" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk stop --dry-run
    assert_output '### "stop" will be deprecated in Makester: 0.3.0
### Replace "stop" with "container-stop"
docker stop my-container'
    [ "$status" -eq 0 ]
}

# bats test_tags=deprecated,dry-run
@test "Warning for deprecated symbol target root" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk root --dry-run
    assert_output '### "root" will be deprecated in Makester: 0.3.0
### Replace "root" with "container-root"
docker exec -ti -u 0 my-container sh || true'
    [ "$status" -eq 0 ]
}

# bats test_tags=deprecated,dry-run
@test "Warning for deprecated symbol target sh" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk sh --dry-run
    assert_output '### "sh" will be deprecated in Makester: 0.3.0
### Replace "sh" with "container-sh"
docker exec -ti my-container sh || true'
    [ "$status" -eq 0 ]
}

# bats test_tags=deprecated,dry-run
@test "Warning for deprecated symbol target bash" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk bash --dry-run
    assert_output '### "bash" will be deprecated in Makester: 0.3.0
### Replace "bash" with "container-bash"
docker exec -ti my-container bash || true'
    [ "$status" -eq 0 ]
}

# bats test_tags=deprecated,dry-run
@test "Warning for deprecated symbol target logs" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk logs --dry-run
    assert_output '### "logs" will be deprecated in Makester: 0.3.0
### Replace "logs" with "container-logs"
docker logs --follow my-container'
    [ "$status" -eq 0 ]
}

# bats test_tags=deprecated,dry-run
@test "Warning for deprecated symbol target status" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk status --dry-run
    assert_output --partial '### "status" will be deprecated in Makester: 0.3.0
### Replace "status" with "container-status"'
    [ "$status" -eq 0 ]
}
