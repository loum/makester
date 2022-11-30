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
    run make -f makefiles/makester.mk -f makefiles/docker.mk docker-help
    assert_output --partial '(makefiles/docker.mk)'
    [ "$status" -eq 0 ]
}

# Docker variables.
#
# MAKESTER__CONTAINER_NAME
# bats test_tags=variables,docker-variables,MAKESTER__CONTAINER_NAME
@test "MAKESTER__CONTAINER_NAME default should be set when calling docker.mk" {
    MAKESTER__DOCKER=docker\
 run make -f makefiles/makester.mk -f makefiles/docker.mk print-MAKESTER__CONTAINER_NAME
    assert_output 'MAKESTER__CONTAINER_NAME=my-container'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,docker-variables,MAKESTER__CONTAINER_NAME
@test "MAKESTER__CONTAINER_NAME override" {
    MAKESTER__DOCKER=docker MAKESTER__CONTAINER_NAME=override\
 run make -f makefiles/makester.mk -f makefiles/docker.mk print-MAKESTER__CONTAINER_NAME
    assert_output 'MAKESTER__CONTAINER_NAME=override'
    [ "$status" -eq 0 ]
}

# MAKESTER__IMAGE_TARGET_TAG
# bats test_tags=variables,docker-variables,MAKESTER__IMAGE_TARGET_TAG
@test "MAKESTER__IMAGE_TARGET_TAG default should be set to HASH when calling docker.mk" {
    MAKESTER__DOCKER=docker\
 run make -f makefiles/makester.mk -f makefiles/docker.mk print-MAKESTER__IMAGE_TARGET_TAG
    assert_output --regexp '^MAKESTER__IMAGE_TARGET_TAG=[0-9a-z]{7}$'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,docker-variables,MAKESTER__IMAGE_TARGET_TAG
@test "MAKESTER__IMAGE_TARGET_TAG override" {
    MAKESTER__DOCKER=docker MAKESTER__IMAGE_TARGET_TAG=override\
 run make -f makefiles/makester.mk -f makefiles/docker.mk print-MAKESTER__IMAGE_TARGET_TAG
    assert_output 'MAKESTER__IMAGE_TARGET_TAG=override'
    [ "$status" -eq 0 ]
}

# MAKESTER__RUN_COMMAND
# bats test_tags=variables,docker-variables,MAKESTER__RUN_COMMAND
@test "MAKESTER__RUN_COMMAND default should be set when calling docker.mk" {
    run make -f makefiles/makester.mk -f makefiles/docker.mk print-MAKESTER__RUN_COMMAND
    assert_output --regexp '^MAKESTER__RUN_COMMAND=.*/docker run --rm --name my-container makefiles:[0-9a-z]{7}$'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,docker-variables,MAKESTER__RUN_COMMAND
@test "MAKESTER__RUN_COMMAND override" {
    MAKESTER__RUN_COMMAND="\$(MAKESTER__DOCKER) run hello-world"\
 run make -f makefiles/makester.mk -f makefiles/docker.mk print-MAKESTER__RUN_COMMAND
    assert_output --regexp 'MAKESTER__RUN_COMMAND=.*/docker run hello-world'
    [ "$status" -eq 0 ]
}

# MAKESTER__BUILD_COMMAND
# bats test_tags=variables,docker-variables,MAKESTER__BUILD_COMMAND
@test "MAKESTER__BUILD_COMMAND default should be set when calling docker.mk" {
    run make -f makefiles/makester.mk -f makefiles/docker.mk print-MAKESTER__BUILD_COMMAND
    assert_output --regexp '^MAKESTER__BUILD_COMMAND=-t makefiles:[0-9a-z]{7} \.$'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,docker-variables,MAKESTER__BUILD_COMMAND
@test "MAKESTER__BUILD_COMMAND override" {
    MAKESTER__BUILD_COMMAND="--no-cache -t \$(MAKESTER__IMAGE_TAG_ALIAS) ."\
 run make -f makefiles/makester.mk -f makefiles/docker.mk print-MAKESTER__BUILD_COMMAND
    assert_output --regexp '^MAKESTER__BUILD_COMMAND=--no-cache -t makefiles:[0-9a-z]{7} \.$'
    [ "$status" -eq 0 ]
}

# MAKESTER__IMAGE_TAG_ALIAS
# bats test_tags=variables,docker-variables,MAKESTER__IMAGE_TAG_ALIAS
@test "MAKESTER__IMAGE_TAG_ALIAS default should be set when calling docker.mk" {
    MAKESTER__PROJECT_NAME=makester\
 run make -f makefiles/makester.mk -f makefiles/docker.mk print-MAKESTER__IMAGE_TAG_ALIAS
    assert_output --regexp '^MAKESTER__IMAGE_TAG_ALIAS=makester:[0-9a-z]{7}$'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,docker-variables,MAKESTER__IMAGE_TAG_ALIAS
@test "MAKESTER__IMAGE_TAG_ALIAS override" {
    MAKESTER__PROJECT_NAME=makester MAKESTER__IMAGE_TARGET_TAG="\$(MAKESTER__VERSION)-\$(MAKESTER__RELEASE_NUMBER)"\
 run make -f makefiles/makester.mk -f makefiles/docker.mk print-MAKESTER__IMAGE_TAG_ALIAS
    assert_output 'MAKESTER__IMAGE_TAG_ALIAS=makester:0.0.0-1'
    [ "$status" -eq 0 ]
}

# Targets.
#
# bats test_tags=targets,docker-targets,image-tag,dry-run
@test "Default Docker image tag: dry" {
    MAKESTER__PROJECT_NAME=makester MAKESTER__DOCKER=docker\
 run make -f makefiles/makester.mk -f makefiles/docker.mk image-tag --dry-run
    assert_output --regexp '^docker tag  makester:[0-9a-z]{7}$'
    [ "$status" -eq 0 ]
}
# bats test_tags=targets,docker-targets,image-tag,dry-run
@test "Default Docker image tag override: dry" {
    MAKESTER__PROJECT_NAME=makester\
 MAKESTER__DOCKER=docker\
 MAKESTER__IMAGE_TARGET_TAG="\$(MAKESTER__VERSION)-\$(MAKESTER__RELEASE_NUMBER)"\
 run make -f makefiles/makester.mk -f makefiles/docker.mk image-tag --dry-run
    assert_output 'docker tag  makester:0.0.0-1'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,docker-targets,image-buildx,dry-run
@test "Default Docker image buildx: dry" {
    MAKESTER__PROJECT_NAME=makester\
 MAKESTER__DOCKER=docker\
 run make -f makefiles/makester.mk -f makefiles/docker.mk image-buildx --dry-run
    assert_output --regexp 'docker buildx build -t makester:[0-9a-z]{7} .'
    [ "$status" -eq 0 ]
}
# bats test_tags=targets,docker-targets,image-buildx,dry-run
@test "Docker image buildx overridden tag: dry" {
    MAKESTER__PROJECT_NAME=makester\
 MAKESTER__DOCKER=docker\
 MAKESTER__IMAGE_TARGET_TAG="\$(MAKESTER__VERSION)-\$(MAKESTER__RELEASE_NUMBER)"\
 run make -f makefiles/makester.mk -f makefiles/docker.mk image-buildx --dry-run
    assert_output 'docker buildx build -t makester:0.0.0-1 .'
    [ "$status" -eq 0 ]
}
