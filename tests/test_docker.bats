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

    assert_failure
}
# bats test_tags=docker-dependencies
@test "Check if Makester is primed: true" {
    run make -f makefiles/makester.mk docker-help

    assert_output --partial '(makefiles/docker.mk)'

    assert_success
}

# Docker variables.
#
# bats test_tags=variables,docker-variables,MAKESTER__CONTAINER_NAME
@test "MAKESTER__CONTAINER_NAME default should be set when calling docker.mk" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk print-MAKESTER__CONTAINER_NAME

    assert_output 'MAKESTER__CONTAINER_NAME=my-container'

    assert_success
}
# bats test_tags=variables,docker-variables,MAKESTER__CONTAINER_NAME
@test "MAKESTER__CONTAINER_NAME override" {
    MAKESTER__DOCKER=docker MAKESTER__CONTAINER_NAME=override\
 run make -f makefiles/makester.mk print-MAKESTER__CONTAINER_NAME

    assert_output 'MAKESTER__CONTAINER_NAME=override'

    assert_success
}

# bats test_tags=variables,docker-variables,MAKESTER__IMAGE_TARGET_TAG
@test "MAKESTER__IMAGE_TARGET_TAG default should be set to HASH when calling docker.mk" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk print-MAKESTER__IMAGE_TARGET_TAG

    assert_output --regexp '^MAKESTER__IMAGE_TARGET_TAG=[0-9a-z]{7}$'

    assert_success
}
# bats test_tags=variables,docker-variables,MAKESTER__IMAGE_TARGET_TAG
@test "MAKESTER__IMAGE_TARGET_TAG override" {
    MAKESTER__DOCKER=docker MAKESTER__IMAGE_TARGET_TAG=override\
 run make -f makefiles/makester.mk print-MAKESTER__IMAGE_TARGET_TAG

    assert_output 'MAKESTER__IMAGE_TARGET_TAG=override'

    assert_success
}

# bats test_tags=variables,docker-variables,MAKESTER__RUN_COMMAND
@test "MAKESTER__RUN_COMMAND default should be set when calling docker.mk" {
    MAKESTER__LOCAL_REGISTRY_RUNNING= run make -f makefiles/makester.mk print-MAKESTER__RUN_COMMAND

    assert_output --regexp '^MAKESTER__RUN_COMMAND=.*/docker run --rm --name my-container makefiles:[0-9a-z]{7}$'

    assert_success
}
# bats test_tags=variables,docker-variables,MAKESTER__RUN_COMMAND
@test "MAKESTER__RUN_COMMAND override" {
    MAKESTER__RUN_COMMAND="\$(MAKESTER__DOCKER) run hello-world"\
 run make -f makefiles/makester.mk print-MAKESTER__RUN_COMMAND

    assert_output --regexp 'MAKESTER__RUN_COMMAND=.*/docker run hello-world'

    assert_success
}

# bats test_tags=variables,docker-variables,MAKESTER__BUILD_COMMAND
@test "MAKESTER__BUILD_COMMAND default should be set when calling docker.mk" {
    MAKESTER__LOCAL_REGISTRY_RUNNING= run make -f makefiles/makester.mk print-MAKESTER__BUILD_COMMAND

    assert_output --regexp '^MAKESTER__BUILD_COMMAND=-t makefiles:[0-9a-z]{7} \.$'

    assert_success
}
# bats test_tags=variables,docker-variables,MAKESTER__BUILD_COMMAND
@test "MAKESTER__BUILD_COMMAND override" {
    MAKESTER__LOCAL_REGISTRY_RUNNING= MAKESTER__BUILD_COMMAND="--no-cache -t \$(MAKESTER__IMAGE_TAG_ALIAS) ."\
 run make -f makefiles/makester.mk print-MAKESTER__BUILD_COMMAND

    assert_output --regexp '^MAKESTER__BUILD_COMMAND=--no-cache -t makefiles:[0-9a-z]{7} \.$'

    assert_success
}

# bats test_tags=variables,docker-variables,MAKESTER__IMAGE_TAG_ALIAS
@test "MAKESTER__IMAGE_TAG_ALIAS default should be set when calling docker.mk" {
    MAKESTER__PROJECT_NAME=makester MAKESTER__LOCAL_REGISTRY_RUNNING=\
 run make -f makefiles/makester.mk print-MAKESTER__IMAGE_TAG_ALIAS

    assert_output --regexp '^MAKESTER__IMAGE_TAG_ALIAS=makester:[0-9a-z]{7}$'

    assert_success
}
# bats test_tags=variables,docker-variables,MAKESTER__IMAGE_TAG_ALIAS
@test "MAKESTER__IMAGE_TAG_ALIAS override" {
    MAKESTER__PROJECT_NAME=makester MAKESTER__LOCAL_REGISTRY_RUNNING=\
 MAKESTER__IMAGE_TARGET_TAG="\$(MAKESTER__VERSION)-\$(MAKESTER__RELEASE_NUMBER)"\
 run make -f makefiles/makester.mk print-MAKESTER__IMAGE_TAG_ALIAS

    assert_output 'MAKESTER__IMAGE_TAG_ALIAS=makester:0.0.0-1'

    assert_success
}
# bats test_tags=variables,docker-variables,MAKESTER__IMAGE_TAG_ALIAS
@test "MAKESTER__IMAGE_TAG_ALIAS with local registry active default should be set when calling docker.mk" {
    MAKESTER__PROJECT_NAME=makester MAKESTER__LOCAL_REGISTRY_RUNNING=makester-registry\
 run make -f makefiles/makester.mk print-MAKESTER__IMAGE_TAG_ALIAS

    assert_output --regexp '^MAKESTER__IMAGE_TAG_ALIAS=localhost:15000/makester:[0-9a-z]{7}$'

    assert_success
}

# bats test_tags=variables,docker-variables,MAKESTER__LOCAL_REGISTRY
@test "MAKESTER__LOCAL_REGISTRY default should be set when calling docker.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__LOCAL_REGISTRY

    assert_output 'MAKESTER__LOCAL_REGISTRY=0.0.0.0:5000'

    assert_success
}
# bats test_tags=variables,docker-variables,MAKESTER__LOCAL_REGISTRY
@test "MAKESTER__LOCAL_REGISTRY override MAKESTER__LOCAL_REGISTRY" {
    MAKESTER__LOCAL_REGISTRY=localhost:5001\
 run make -f makefiles/makester.mk print-MAKESTER__LOCAL_REGISTRY

    assert_output --regexp '^MAKESTER__LOCAL_REGISTRY=localhost:5001$'

    assert_success
}

# bats test_tags=variables,docker-variables,MAKESTER__LOCAL_REGISTRY_IMAGE
@test "MAKESTER__LOCAL_REGISTRY_IMAGE default should be set when calling docker.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__LOCAL_REGISTRY_IMAGE

    assert_output 'MAKESTER__LOCAL_REGISTRY_IMAGE=registry:2'

    assert_success
}
# bats test_tags=variables,docker-variables,MAKESTER__LOCAL_REGISTRY_IMAGE
@test "MAKESTER__LOCAL_REGISTRY_IMAGE override" {
    MAKESTER__LOCAL_REGISTRY_IMAGE=registry:3\
 run make -f makefiles/makester.mk print-MAKESTER__LOCAL_REGISTRY_IMAGE

    assert_output 'MAKESTER__LOCAL_REGISTRY_IMAGE=registry:3'

    assert_success
}

# bats test_tags=variables,docker-variables,MAKESTER__BUILDKIT_BUILDER_NAME
@test "MAKESTER__BUILDKIT_BUILDER_NAME default should be set when calling docker.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__BUILDKIT_BUILDER_NAME

    assert_output 'MAKESTER__BUILDKIT_BUILDER_NAME=multiarch'

    assert_success
}
# bats test_tags=variables,docker-variables,MAKESTER__BUILDKIT_BUILDER_NAME
@test "MAKESTER__BUILDKIT_BUILDER_NAME override" {
    MAKESTER__BUILDKIT_BUILDER_NAME=supa-builder\
 run make -f makefiles/makester.mk print-MAKESTER__BUILDKIT_BUILDER_NAME

    assert_output 'MAKESTER__BUILDKIT_BUILDER_NAME=supa-builder'

    assert_success
}

# Targets.
#
# bats test_tags=targets,docker-targets,image,image-tag,dry-run
@test "Default Docker image tag: dry" {
    MAKESTER__PROJECT_NAME=makester MAKESTER__DOCKER=docker MAKESTER__LOCAL_REGISTRY_RUNNING=\
 run make -f makefiles/makester.mk image-tag --dry-run

    assert_output --regexp '^docker tag  makester:[0-9a-z]{7}$'

    assert_success
}
# bats test_tags=targets,docker-targets,image,image-tag,dry-run
@test "Default Docker image tag override: dry" {
    MAKESTER__PROJECT_NAME=makester MAKESTER__DOCKER=docker MAKESTER__LOCAL_REGISTRY_RUNNING=\
 MAKESTER__IMAGE_TARGET_TAG="\$(MAKESTER__VERSION)-\$(MAKESTER__RELEASE_NUMBER)"\
 run make -f makefiles/makester.mk image-tag --dry-run

    assert_output 'docker tag  makester:0.0.0-1'

    assert_success
}

# bats test_tags=targets,docker-targets,image,image-buildx,dry-run
@test "Default Docker image buildx: dry" {
    MAKESTER__PROJECT_NAME=makester MAKESTER__DOCKER_PLATFORM=linux/amd64\
 MAKESTER__DOCKER=docker MAKESTER__LOCAL_REGISTRY_RUNNING=\
 run make -f makefiles/makester.mk image-buildx --dry-run

    assert_output --regexp 'docker buildx build --platform linux/amd64 --load -t makester:[0-9a-z]{7} .'

    assert_success
}
# bats test_tags=targets,docker-targets,image,image-buildx,dry-run
@test "Default Docker image buildx MAKESTER__DOCKER_PLATFORM override: dry" {
    MAKESTER__PROJECT_NAME=makester MAKESTER__DOCKER_PLATFORM=linux/arm64,linux/amd64\
 MAKESTER__DOCKER=docker MAKESTER__LOCAL_REGISTRY_RUNNING=\
 run make -f makefiles/makester.mk image-buildx --dry-run

    assert_output --regexp 'docker buildx build --platform linux/arm64,linux/amd64 --load -t makester:[0-9a-z]{7} .'

    assert_success
}
# bats test_tags=targets,docker-targets,image,image-buildx,dry-run
@test "Docker image buildx overridden tag: dry" {
    MAKESTER__PROJECT_NAME=makester MAKESTER__DOCKER_PLATFORM=linux/amd64 MAKESTER__LOCAL_REGISTRY_RUNNING=\
 MAKESTER__DOCKER=docker MAKESTER__IMAGE_TARGET_TAG="\$(MAKESTER__VERSION)-\$(MAKESTER__RELEASE_NUMBER)"\
 run make -f makefiles/makester.mk image-buildx --dry-run

    assert_output 'docker buildx build --platform linux/amd64 --load -t makester:0.0.0-1 .'

    assert_success
}

# bats test_tags=targets,docker-targets,container,container-run,dry-run
@test "Container run with container-run: dry" {
    MAKESTER__DOCKER=docker MAKESTER__LOCAL_REGISTRY_RUNNING=\
 run make -f makefiles/makester.mk container-run --dry-run

    assert_output --regexp 'docker run --rm --name my-container makefiles:[0-9a-z]{7}'

    assert_success
}

# bats test_tags=targets,docker-targets,container,container-stop,dry-run
@test "Container stop with container-stop: dry" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk container-stop --dry-run

    assert_output --regexp 'docker stop my-container'

    assert_success
}

# bats test_tags=targets,docker-targets,container,container-root,dry-run
@test "Container root shell with container-root: dry" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk container-root --dry-run

    assert_output 'docker exec -ti -u 0 my-container sh || true'

    assert_success
}

# bats test_tags=targets,docker-targets,container,container-sh,dry-run
@test "Container shell with container-shell: dry" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk container-sh --dry-run

    assert_output 'docker exec -ti my-container sh || true'

    assert_success
}

# bats test_tags=targets,docker-targets,container,container-bash,dry-run
@test "Container bash with container-bash: dry" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk container-bash --dry-run

    assert_output 'docker exec -ti my-container bash || true'

    assert_success
}

# bats test_tags=targets,docker-targets,container,container-logs,dry-run
@test "Container bash with container-logs: dry" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk container-logs --dry-run

    assert_output 'docker logs --follow my-container'

    assert_success
}

# bats test_tags=targets,docker-targets,image-registry-start,dry-run
@test "Local Docker image registry start: dry" {
    MAKESTER__DOCKER=docker MAKESTER__LOCAL_REGISTRY_RUNNING=\
 run make -f makefiles/makester.mk image-registry-start --dry-run

    assert_output --regexp '### Starting local Docker image registry ...
docker run --rm -d\\
 -e REGISTRY_HTTP_ADDR=0.0.0.0:5000\\
 -p 15000:5000\\
 --name makester-registry\\
 registry:2
.*/bin/makester backoff [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ 15000 --detail "Local registry server"'

    assert_success
}
# bats test_tags=targets,docker-targets,image-registry-start,dry-run
@test "Local Docker image registry start MAKESTER__LOCAL_REGISTRY_PORT override: dry" {
    MAKESTER__LOCAL_REGISTRY_PORT=5001 MAKESTER__DOCKER=docker MAKESTER__LOCAL_REGISTRY_RUNNING=\
 run make -f makefiles/makester.mk image-registry-start --dry-run

    assert_output --regexp '### Starting local Docker image registry ...
docker run --rm -d\\
 -e REGISTRY_HTTP_ADDR=0.0.0.0:5000\\
 -p 5001:5000\\
 --name makester-registry\\
 registry:2
.*/bin/makester backoff [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ 5001 --detail "Local registry server"'

    assert_success
}
# bats test_tags=targets,docker-targets,image-registry-start,dry-run
@test "Local Docker image registry start MAKESTER__LOCAL_REGISTRY_IMAGE override: dry" {
    MAKESTER__LOCAL_REGISTRY_IMAGE=registry:3 MAKESTER__DOCKER=docker MAKESTER__LOCAL_REGISTRY_RUNNING=\
 run make -f makefiles/makester.mk image-registry-start --dry-run

    assert_output --regexp '### Starting local Docker image registry ...
docker run --rm -d\\
 -e REGISTRY_HTTP_ADDR=0.0.0.0:5000\\
 -p 15000:5000\\
 --name makester-registry\\
 registry:3
.*/bin/makester backoff [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ 15000 --detail "Local registry server"'

    assert_success
}

# bats test_tags=targets,docker-targets,image-buildx-builder,dry-run
@test "BuildKit builder create and use: dry" {
    MAKESTER__DOCKER=docker run make -f makefiles/makester.mk image-buildx-builder --dry-run

    assert_output '### Creating BuildKit builder "multiarch" (if required) ...
docker buildx inspect multiarch ||\
 docker buildx create --driver-opt "network=host" --name multiarch --use'

    assert_success
}
# bats test_tags=targets,docker-targets,image-buildx-builder,dry-run
@test "BuildKit builder create and use with MAKESTER__BUILDKIT_BUILDER_NAME override: dry" {
    MAKESTER__BUILDKIT_BUILDER_NAME=supa-builder MAKESTER__DOCKER=docker\
 run make -f makefiles/makester.mk image-buildx-builder --dry-run

    assert_output '### Creating BuildKit builder "supa-builder" (if required) ...
docker buildx inspect supa-builder ||\
 docker buildx create --driver-opt "network=host" --name supa-builder --use'

    assert_success
}

# bats test_tags=targets,docker-targets,container,container-status,dry-run
@test "Container status when image container not running: dry" {
    MAKESTER__DOCKER=docker MAKESTER__CONTAINER_NAME=supa-container MAKESTER__RUNNING_CONTAINER=\
 run make -f makefiles/makester.mk container-status --dry-run

    assert_output '### "supa-container" image container is not running.
### Run "make container-run" to start.'

    assert_success
}
# bats test_tags=targets,docker-targets,container,container-status,dry-run
@test "Container status when image container running: dry" {
    MAKESTER__DOCKER=docker MAKESTER__CONTAINER_NAME=supa-container\
 MAKESTER__RUNNING_CONTAINER=supa-container\
 run make -f makefiles/makester.mk container-status --dry-run

    assert_output '### "supa-container" image container is running.
### Run "make container-stop" to terminate.'

    assert_success
}
