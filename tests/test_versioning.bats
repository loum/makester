# Versioning test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --file-filter versioning tests
#
# bats file_tags=versioning
setup_file() {
    export MAKESTER__WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/makester-XXXXXX")
    export MAKESTER__GITVERSION_CONFIG=sample/GitVersion.yml
}
setup() {
    load 'test_helper/common-setup'
    _common_setup
}
teardown_file() {
    make -f makefiles/makester.mk -f makefiles/docker.mk -f makefiles/versioning.mk gitversion-clear
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
    MAKESTER__DOCKER=dummy run make -f makefiles/versioning.mk
    assert_output --partial '(makefiles/versioning.mk)'
    [ "$status" -eq 0 ]
}

# Versioning variables.
#
# MAKESTER__GITVERSION_CONFIG
# bats test_tags=variables,versioning-variables,MAKESTER__GITVERSION_CONFIG
@test "MAKESTER__GITVERSION_CONFIG default should be set when calling versioning.mk" {
    MAKESTER__DOCKER=dummy\
 run make -f makefiles/makester.mk -f makefiles/versioning.mk print-MAKESTER__GITVERSION_CONFIG
    assert_output 'MAKESTER__GITVERSION_CONFIG=sample/GitVersion.yml'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,versioning-variables,MAKESTER__GITVERSION_CONFIG
@test "MAKESTER__GITVERSION_CONFIG override" {
    MAKESTER__DOCKER=dummy MAKESTER__GITVERSION_CONFIG=Override.yml\
 run make -f makefiles/makester.mk -f makefiles/versioning.mk print-MAKESTER__GITVERSION_CONFIG
    assert_output 'MAKESTER__GITVERSION_CONFIG=Override.yml'
    [ "$status" -eq 0 ]
}

# MAKESTER__GITVERSION_VARIABLE
# bats test_tags=variables,versioning-variables,MAKESTER__GITVERSION_VARIABLE
@test "MAKESTER__GITVERSION_VARIABLE default should be set when calling versioning.mk" {
    MAKESTER__DOCKER=dummy\
 run make -f makefiles/makester.mk -f makefiles/versioning.mk print-MAKESTER__GITVERSION_VARIABLE
    assert_output 'MAKESTER__GITVERSION_VARIABLE=AssemblySemFileVer'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,versioning-variables,MAKESTER__GITVERSION_VARIABLE
@test "MAKESTER__GITVERSION_VARIABLE override" {
    MAKESTER__DOCKER=dummy MAKESTER__GITVERSION_VARIABLE=Override\
 run make -f makefiles/makester.mk -f makefiles/versioning.mk print-MAKESTER__GITVERSION_VARIABLE
    assert_output 'MAKESTER__GITVERSION_VARIABLE=Override'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,versioning-variables,MAKESTER__VERSION_FILE
@test "MAKESTER__VERSION_FILE default should be set when calling versioning.mk" {
    MAKESTER__DOCKER=dummy\
 run make -f makefiles/makester.mk -f makefiles/versioning.mk print-MAKESTER__VERSION_FILE
    assert_output "MAKESTER__VERSION_FILE=$MAKESTER__WORK_DIR/VERSION"
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,versioning-variables,MAKESTER__VERSION_FILE
@test "MAKESTER__VERSION_FILE override" {
    MAKESTER__DOCKER=dummy MAKESTER__VERSION_FILE=my_package/VERSION\
 run make -f makefiles/makester.mk -f makefiles/versioning.mk print-MAKESTER__VERSION_FILE
    assert_output 'MAKESTER__VERSION_FILE=my_package/VERSION'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,versioning-variables,MAKESTER__GITVERSION_VERSION
@test "MAKESTER__GITVERSION_VERSION when MAKESTER__ARCH is arm64" {
    MAKESTER__DOCKER=dummy MAKESTER__ARCH=arm64\
 run make -f makefiles/makester.mk -f makefiles/versioning.mk print-MAKESTER__GITVERSION_VERSION
    assert_output "MAKESTER__GITVERSION_VERSION=5.11.1-ubuntu.20.04-6.0-arm64"
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,versioning-variables,MAKESTER__GITVERSION_VERSION
@test "MAKESTER__GITVERSION_VERSION when MAKESTER__ARCH is other than arm64" {
    MAKESTER__DOCKER=dummy MAKESTER__ARCH=anything_else\
 run make -f makefiles/makester.mk -f makefiles/versioning.mk print-MAKESTER__GITVERSION_VERSION
    assert_output "MAKESTER__GITVERSION_VERSION=5.11.1-alpine.3.13-6.0"
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,versioning-variables,MAKESTER__GITVERSION_VERSION
@test "MAKESTER__GITVERSION_VERSION override" {
    MAKESTER__DOCKER=dummy MAKESTER__GITVERSION_VERSION=override\
 run make -f makefiles/makester.mk -f makefiles/versioning.mk print-MAKESTER__GITVERSION_VERSION
    assert_output 'MAKESTER__GITVERSION_VERSION=override'
    [ "$status" -eq 0 ]
}

# Targets.
#
# bats test_tags=target,gitversion-version
@test "GitVersion version" {
    MAKESTER__GITVERSION_CONFIG=sample/GitVersion.yml\
 run make -f makefiles/makester.mk -f makefiles/docker.mk -f makefiles/versioning.mk gitversion-version
    assert_output --regexp '[0-9]+\.[0-9]+\.[0-9]+\+Branch.support-5.x.Sha.[0-9a-z]+'
    [ "$status" -eq 0 ]
}

# bats test_tags=target,gitversion-release
@test "Makester sample/GitVersion.yml release version" {
    MAKESTER__GITVERSION_CONFIG=sample/GitVersion.yml\
 run make -f makefiles/makester.mk -f makefiles/docker.mk -f makefiles/versioning.mk gitversion-release
    assert_output --regexp "### Filtering GitVersion variable: AssemblySemFileVer
### Removing $MAKESTER__WORK_DIR/versioning
### Creating Makester working directory \"$MAKESTER__WORK_DIR\"
### MAKESTER__RELEASE_VERSION: [0-9]+\.[0-9]+\.[0-9]+[ab]{0,1}[0-9]{0,3}"
    [ "$status" -eq 0 ]
}
# bats test_tags=target,gitversion-release
@test "Makester sample/GitVersion.yml release version with overridden version variable" {
    MAKESTER__GITVERSION_CONFIG=sample/GitVersion.yml MAKESTER__GITVERSION_VARIABLE=ShortSha\
 run make -f makefiles/makester.mk -f makefiles/docker.mk -f makefiles/versioning.mk gitversion-release
    assert_output --regexp "### Filtering GitVersion variable: ShortSha
### Removing $MAKESTER__WORK_DIR/versioning
### Creating Makester working directory \"$MAKESTER__WORK_DIR\"
### MAKESTER__RELEASE_VERSION: [0-9a-z]{0,7}"
    [ "$status" -eq 0 ]
}

# bats test_tags=target,gitversion-release-ro
@test "Makester sample/GitVersion.yml release version read only" {
    MAKESTER__GITVERSION_CONFIG=sample/GitVersion.yml\
 run make -f makefiles/makester.mk -f makefiles/docker.mk -f makefiles/versioning.mk gitversion-release-ro
    assert_output --regexp "### Filtering GitVersion variable: AssemblySemFileVer
### Removing $MAKESTER__WORK_DIR/versioning
### Creating Makester working directory \"$MAKESTER__WORK_DIR\"
### MAKESTER__RELEASE_VERSION: [0-9]+\.[0-9]+\.[0-9]+[ab]{0,1}[0-9]{0,3}"
    [ "$status" -eq 0 ]
}
# bats test_tags=target,gitversion-release-ro
@test "Makester sample/GitVersion.yml release version with overridden version variable read only" {
    MAKESTER__GITVERSION_CONFIG=sample/GitVersion.yml MAKESTER__GITVERSION_VARIABLE=ShortSha\
 run make -f makefiles/makester.mk -f makefiles/docker.mk -f makefiles/versioning.mk gitversion-release-ro
    assert_output --regexp "### Filtering GitVersion variable: ShortSha
### Removing $MAKESTER__WORK_DIR/versioning
### Creating Makester working directory \"$MAKESTER__WORK_DIR\"
### MAKESTER__RELEASE_VERSION: [0-9a-z]{0,7}"
    [ "$status" -eq 0 ]
}

# Symbol deprecation.
#
# bats test_tags=deprecated,debug
@test "Warning for deprecated symbol target release-version" {
    MAKESTER__GITVERSION_CONFIG=sample/GitVersion.yml\
 run make -f makefiles/makester.mk -f makefiles/docker.mk -f makefiles/versioning.mk release-version
    assert_output --regexp "### \"release-version\" will be deprecated in Makester: 0.3.0
### Replace \"release-version\" with \"gitversion-release\"
### Filtering GitVersion variable: AssemblySemFileVer
### Removing $MAKESTER__WORK_DIR/versioning
### Creating Makester working directory \"$MAKESTER__WORK_DIR\"
### MAKESTER__RELEASE_VERSION: [0-9]+\.[0-9]+\.[0-9]+[ab]{0,1}[0-9]{0,3}"
    [ "$status" -eq 0 ]
}
