# Test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats tests/test_versioning.bats
#
# bats file_tags=versioning
setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    export MAKESTER__WORK_DIR=$(mktemp -d -t makester-XXXXXX)
}

teardown() {
    MAKESTER__PROJECT_DIR=$PWD make -f makefiles/makester.mk -f makefiles/docker.mk -f makefiles/versioning.mk gitversion-clear
    MAKESTER__WORK_DIR=$MAKESTER__WORK_DIR make -f makefiles/makester.mk makester-work-dir-rm
}

# Versioning include dependencies.
#
# Docker.
# bats test_tags=versioning-docker
@test "Check docker executable dependency without makester.mk" {
    run make -f makefiles/versioning.mk
    assert_output --partial '### Add the following include statement to your Makefile
include makester/makefiles/docker.mk'
    [ "$status" -eq 2 ]
}

# bats test_tags=versioning-docker
@test "Check docker executable dependency with makester.mk" {
    DOCKER=dummy run make -f makefiles/versioning.mk
    assert_output --partial '(makefiles/versioning.mk)'
    [ "$status" -eq 0 ]
}

# Versioning variables.
#
# MAKESTER__GITVERSION_CONFIG
# bats test_tags=MAKESTER__GITVERSION_CONFIG
@test "MAKESTER__GITVERSION_CONFIG default should be set when calling versioning.mk" {
    DOCKER=dummy run make -f makefiles/makester.mk -f makefiles/versioning.mk print-MAKESTER__GITVERSION_CONFIG
    assert_output 'MAKESTER__GITVERSION_CONFIG=GitVersion.yml'
    [ "$status" -eq 0 ]
}
# bats test_tags=MAKESTER__GITVERSION_CONFIG
@test "MAKESTER__GITVERSION_CONFIG override" {
    DOCKER=dummy MAKESTER__GITVERSION_CONFIG=Override.yml\
 run make -f makefiles/makester.mk -f makefiles/versioning.mk print-MAKESTER__GITVERSION_CONFIG
    assert_output 'MAKESTER__GITVERSION_CONFIG=Override.yml'
    [ "$status" -eq 0 ]
}

# MAKESTER__GITVERSION_VARIABLE
# bats test_tags=MAKESTER__GITVERSION_VARIABLE
@test "MAKESTER__GITVERSION_VARIABLE default should be set when calling versioning.mk" {
    DOCKER=dummy run make -f makefiles/makester.mk -f makefiles/versioning.mk print-MAKESTER__GITVERSION_VARIABLE
    assert_output 'MAKESTER__GITVERSION_VARIABLE=AssemblySemFileVer'
    [ "$status" -eq 0 ]
}
# bats test_tags=MAKESTER__GITVERSION_VARIABLE
@test "MAKESTER__GITVERSION_VARIABLE override" {
    DOCKER=dummy MAKESTER__GITVERSION_VARIABLE=Override\
 run make -f makefiles/makester.mk -f makefiles/versioning.mk print-MAKESTER__GITVERSION_VARIABLE
    assert_output 'MAKESTER__GITVERSION_VARIABLE=Override'
    [ "$status" -eq 0 ]
}

# MAKESTER__GITVERSION_VERSION
# bats test_tags=MAKESTER__GITVERSION_VERSION
@test "MAKESTER__GITVERSION_VERSION default should be set when calling versioning.mk" {
    DOCKER=dummy run make -f makefiles/makester.mk -f makefiles/versioning.mk print-MAKESTER__GITVERSION_VERSION
    assert_output 'MAKESTER__GITVERSION_VERSION=latest'
    [ "$status" -eq 0 ]
}
# bats test_tags=MAKESTER__GITVERSION_VERSION
@test "MAKESTER__GITVERSION_VERSION override" {
    DOCKER=dummy MAKESTER__GITVERSION_VERSION=override\
 run make -f makefiles/makester.mk -f makefiles/versioning.mk print-MAKESTER__GITVERSION_VERSION
    assert_output 'MAKESTER__GITVERSION_VERSION=override'
    [ "$status" -eq 0 ]
}

# bats test_tags=MAKESTER__PACKAGE_NAME
@test "MAKESTER__PACKAGE_NAME default should be set when calling versioning.mk" {
    DOCKER=dummy run make -f makefiles/makester.mk -f makefiles/versioning.mk print-MAKESTER__PACKAGE_NAME
    assert_output 'MAKESTER__PACKAGE_NAME=makefiles'
    [ "$status" -eq 0 ]
}
# bats test_tags=MAKESTER__PACKAGE_NAME
@test "MAKESTER__PACKAGE_NAME override" {
    DOCKER=dummy MAKESTER__PACKAGE_NAME=override\
 run make -f makefiles/makester.mk -f makefiles/versioning.mk print-MAKESTER__PACKAGE_NAME
    assert_output 'MAKESTER__PACKAGE_NAME=override'
    [ "$status" -eq 0 ]
}

# Targets.
#
# bats test_tags=gitversion-version
@test "GitVersion version" {
    MAKESTER__PROJECT_DIR=$PWD MAKESTER__GITVERSION_CONFIG=sample/GitVersion.yml\
 run make -f makefiles/makester.mk -f makefiles/docker.mk -f makefiles/versioning.mk gitversion-version
    assert_output --regexp '[0-9]+\.[0-9]+\.[0-9]+\+Branch.support-5.x.Sha.[0-9a-z]+'
    [ "$status" -eq 0 ]
}

# bats test_tags=MAKESTER__RELEASE_VERSION,release-version
@test "Makester sample/GitVersion.yml release version" {
    MAKESTER__PROJECT_DIR=$PWD\
 MAKESTER__GITVERSION_CONFIG=sample/GitVersion.yml\
 run make -f makefiles/makester.mk -f makefiles/docker.mk -f makefiles/versioning.mk release-version
### MAKESTER__RELEASE_VERSION: "[0-9]+\.[0-9]+\.[0-9a-z]+"'
    [ "$status" -eq 0 ]
}
# bats test_tags=MAKESTER__RELEASE_VERSION,release-version
@test "Makester sample/GitVersion.yml release version with overridden version variable" {
    MAKESTER__PROJECT_DIR=$PWD MAKESTER__GITVERSION_CONFIG=sample/GitVersion.yml MAKESTER__GITVERSION_VARIABLE=ShortSha\
 run make -f makefiles/makester.mk -f makefiles/docker.mk -f makefiles/versioning.mk release-version
    assert_output --regexp '### Filtering GitVersion variable: ShortSha
### MAKESTER__RELEASE_VERSION: "[0-9a-z]+"'
    [ "$status" -eq 0 ]
}

# bats test_tags=release-version
@test "Default GitVersion.yml release version" {
    MAKESTER__PROJECT_DIR=$PWD\
 run make -f makefiles/makester.mk -f makefiles/docker.mk -f makefiles/versioning.mk release-version
    assert_output --regexp '### Filtering GitVersion variable: AssemblySemFileVer
### MAKESTER__RELEASE_VERSION: "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"'
    [ "$status" -eq 0 ]
}
# bats test_tags=release-version
@test "Default GitVersion.yml release version with overridden version variable" {
    MAKESTER__PROJECT_DIR=$PWD MAKESTER__GITVERSION_VARIABLE=ShortSha\
 run make -f makefiles/makester.mk -f makefiles/docker.mk -f makefiles/versioning.mk release-version
    assert_output --regexp '### Filtering GitVersion variable: ShortSha
### MAKESTER__RELEASE_VERSION: "[0-9a-z]+"'
    [ "$status" -eq 0 ]
}
