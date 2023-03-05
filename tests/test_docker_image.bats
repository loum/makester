# Test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags docker-image tests
#
# bats file_tags=docker-image
setup_file() {
    MAKESTER__LOCAL_REGISTRY_RUNNING= make -f sample/Makefile image-build
}
setup() {
    load 'test_helper/common-setup'
    _common_setup
}
teardown_file() {
    MAKESTER__LOCAL_REGISTRY_RUNNING= make -f sample/Makefile image-rm
}

# Targets.
#
# bats test_tags=targets,docker-targets,image-build,dry-run
@test "hello-world Docker image build: dry" {
    MAKESTER__LOCAL_REGISTRY_RUNNING= MAKESTER__DOCKER=docker run make -f sample/Makefile image-build --dry-run
    assert_output --regexp 'docker build -t supa-cool-repo/my-project:[0-9a-z]{7} sample'
    [ "$status" -eq 0 ]
}
# bats test_tags=targets,docker-targets,image-build,dry-run
@test "hello-world Docker image build with Dockerfile PATH override: dry" {
    MAKESTER__LOCAL_REGISTRY_RUNNING= MAKESTER__BUILD_PATH=sample MAKESTER__DOCKER=docker\
 MAKESTER__REPO_NAME=supa-cool-repo MAKESTER__PROJECT_NAME=my-project\
 MAKESTER__DOCKER_PLATFORM=linux/amd64 MAKESTER__DOCKER_DRIVER_OUTPUT=push\
 run make -f makefiles/makester.mk image-buildx --dry-run
    assert_output --regexp 'docker buildx build --platform linux/amd64 --push -t supa-cool-repo/my-project:[0-9a-z]{7} sample'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,docker-targets,image-search,dry-run
@test "hello-world Docker image search: dry" {
    MAKESTER__LOCAL_REGISTRY_RUNNING= MAKESTER__DOCKER=docker run make -f sample/Makefile image-search --dry-run
    assert_output 'docker images "supa-cool-repo/my-project*"'
    [ "$status" -eq 0 ]
}
# bats test_tags=targets,docker-targets,image-search
@test "hello-world Docker image search" {
    MAKESTER__LOCAL_REGISTRY_RUNNING= MAKESTER__DOCKER=docker run make -f sample/Makefile image-search
    assert_output --regexp 'supa-cool-repo/my-project   [0-9a-z]{7}   [0-9a-z]{12}'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,docker-targets,image-run,dry-run
@test "hello-world Docker image run: dry" {
    MAKESTER__LOCAL_REGISTRY_RUNNING= MAKESTER__DOCKER=docker run make -f sample/Makefile run --dry-run
    assert_output --regexp 'docker run --rm --name mega-container supa-cool-repo/my-project:[0-9a-z]{7}'
    [ "$status" -eq 0 ]
}
# bats test_tags=targets,docker-targets,image-run
@test "hello-world Docker image run" {
    MAKESTER__LOCAL_REGISTRY_RUNNING= MAKESTER__DOCKER=docker run make -f sample/Makefile run
    assert_output --partial 'Hello from Docker!
This message shows that your installation appears to be working correctly.'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,docker-targets,image-tag,dry-run
@test "hello-world Docker image tag: dry" {
    MAKESTER__LOCAL_REGISTRY_RUNNING= MAKESTER__DOCKER=docker run make -f sample/Makefile image-tag --dry-run
    assert_output --regexp 'docker tag [0-9a-z]{12} supa-cool-repo/my-project:[0-9a-z]{7}'
    [ "$status" -eq 0 ]
}
# bats test_tags=targets,docker-targets,image-tag
@test "hello-world Docker image tag" {
    MAKESTER__LOCAL_REGISTRY_RUNNING= MAKESTER__DOCKER=docker\
 MAKESTER__IMAGE_TARGET_TAG="\$(MAKESTER__VERSION)-\$(MAKESTER__RELEASE_NUMBER)"\
 run make -f sample/Makefile image-tag --dry-run
    assert_output --regexp 'docker tag [0-9a-z]{12} supa-cool-repo/my-project:0.0.0-1'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,docker-targets,image-tag-latest,dry-run
@test "hello-world Docker image tag latest: dry" {
    MAKESTER__LOCAL_REGISTRY_RUNNING= MAKESTER__DOCKER=docker\
 run make -f sample/Makefile image-tag-latest --dry-run
    assert_output --regexp '### Tagging container image "supa-cool-repo/my-project" as "latest"
docker tag [0-9a-z]{12} supa-cool-repo/my-project:latest'
    [ "$status" -eq 0 ]
}
# bats test_tags=targets,docker-targets,image-tag-latest-rm,dry-run
@test "hello-world Docker image tag latest remove: dry" {
    MAKESTER__LOCAL_REGISTRY_RUNNING= MAKESTER__DOCKER=docker\
 run make -f sample/Makefile image-tag-latest-rm --dry-run
    assert_output '### Removing tag "latest" from container image "supa-cool-repo/my-project"
docker rmi supa-cool-repo/my-project:latest'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,docker-targets,image-tag-version,dry-run
@test "hello-world Docker image tag version: dry" {
    MAKESTER__LOCAL_REGISTRY_RUNNING= MAKESTER__DOCKER=docker\
 run make -f sample/Makefile image-tag-version --dry-run
    assert_output --regexp '### Tagging container image "supa-cool-repo/my-project" as "0.0.0-1"
docker tag [0-9a-z]{12} supa-cool-repo/my-project:0.0.0-1'
    [ "$status" -eq 0 ]
}
# bats test_tags=targets,docker-targets,image-tag-version-rm,dry-run
@test "hello-world Docker image tag version remove: dry" {
    MAKESTER__LOCAL_REGISTRY_RUNNING= MAKESTER__DOCKER=docker\
 run make -f sample/Makefile image-tag-version-rm --dry-run
    assert_output '### Removing tag "0.0.0-1" from container image "supa-cool-repo/my-project"
docker rmi supa-cool-repo/my-project:0.0.0-1'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,docker-targets,image-tag-main,dry-run
@test "hello-world Docker image tag main: dry" {
    MAKESTER__LOCAL_REGISTRY_RUNNING= MAKESTER__DOCKER=docker\
 run make -f sample/Makefile image-tag-main --dry-run
    assert_output --regexp '### Tagging container image "supa-cool-repo/my-project" as "0.0.0"
docker tag [0-9a-z]{12} supa-cool-repo/my-project:0.0.0'
    [ "$status" -eq 0 ]
}
# bats test_tags=targets,docker-targets,image-tag-main-rm,dry-run
@test "hello-world Docker image tag main remove: dry" {
    MAKESTER__LOCAL_REGISTRY_RUNNING= MAKESTER__DOCKER=docker\
 run make -f sample/Makefile image-tag-main-rm --dry-run
    assert_output '### Removing tag "0.0.0" from container image "supa-cool-repo/my-project"
docker rmi supa-cool-repo/my-project:0.0.0'
    [ "$status" -eq 0 ]
}
