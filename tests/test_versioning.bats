# Versioning test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags versioning tests
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
    make -f makefiles/makester.mk gitversion-clear
    MAKESTER__WORK_DIR=$MAKESTER__WORK_DIR make -f makefiles/makester.mk makester-work-dir-rm
}

# Versioning include dependencies.
#
# Makester.
# bats test_tags=versioning-dependencies
@test "Check if Makester is primed: false" {
    run make -f makefiles/versioning.mk

    assert_output --partial '### Add the following include statement to your Makefile
include makester/makefiles/makester.mk'

    assert_failure
}
# bats test_tags=versioning-dependencies
@test "Check if Makester is primed: true" {
    run make -f makefiles/makester.mk versioning-help

    assert_output --partial '(makefiles/versioning.mk)'

    assert_success
}

# Versioning variables.
#
# MAKESTER__GITVERSION_CONFIG
# bats test_tags=variables,versioning-variables,MAKESTER__GITVERSION_CONFIG
@test "MAKESTER__GITVERSION_CONFIG default should be set when calling versioning.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__GITVERSION_CONFIG

    assert_output 'MAKESTER__GITVERSION_CONFIG=sample/GitVersion.yml'

    assert_success
}
# bats test_tags=variables,versioning-variables,MAKESTER__GITVERSION_CONFIG
@test "MAKESTER__GITVERSION_CONFIG override" {
    MAKESTER__GITVERSION_CONFIG=Override.yml\
 run make -f makefiles/makester.mk print-MAKESTER__GITVERSION_CONFIG

    assert_output 'MAKESTER__GITVERSION_CONFIG=Override.yml'

    assert_success
}

# MAKESTER__GITVERSION_VARIABLE
# bats test_tags=variables,versioning-variables,MAKESTER__GITVERSION_VARIABLE
@test "MAKESTER__GITVERSION_VARIABLE default should be set when calling versioning.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__GITVERSION_VARIABLE

    assert_output 'MAKESTER__GITVERSION_VARIABLE=AssemblySemFileVer'

    assert_success
}
# bats test_tags=variables,versioning-variables,MAKESTER__GITVERSION_VARIABLE
@test "MAKESTER__GITVERSION_VARIABLE override" {
    MAKESTER__GITVERSION_VARIABLE=Override\
 run make -f makefiles/makester.mk print-MAKESTER__GITVERSION_VARIABLE

    assert_output 'MAKESTER__GITVERSION_VARIABLE=Override'

    assert_success
}

# bats test_tags=variables,versioning-variables,MAKESTER__GITVERSION_VERSION
@test "MAKESTER__GITVERSION_VERSION when MAKESTER__ARCH is arm64" {
    MAKESTER__ARCH=arm64 run make -f makefiles/makester.mk print-MAKESTER__GITVERSION_VERSION

    assert_output "MAKESTER__GITVERSION_VERSION=5.12.0-ubuntu.20.04-6.0-arm64"

    assert_success
}
# bats test_tags=variables,versioning-variables,MAKESTER__GITVERSION_VERSION
@test "MAKESTER__GITVERSION_VERSION when MAKESTER__ARCH is other than arm64" {
    MAKESTER__ARCH=anything_else run make -f makefiles/makester.mk print-MAKESTER__GITVERSION_VERSION

    assert_output "MAKESTER__GITVERSION_VERSION=5.12.0-alpine.3.14-6.0"

    assert_success
}
# bats test_tags=variables,versioning-variables,MAKESTER__GITVERSION_VERSION
@test "MAKESTER__GITVERSION_VERSION override" {
    MAKESTER__GITVERSION_VERSION=override run make -f makefiles/makester.mk print-MAKESTER__GITVERSION_VERSION

    assert_output 'MAKESTER__GITVERSION_VERSION=override'

    assert_success
}

# Targets.
#
# bats test_tags=target,gitversion-version
@test "GitVersion version" {
    MAKESTER__GITVERSION_CONFIG=sample/GitVersion.yml run make -f makefiles/makester.mk gitversion-version

    assert_output --regexp '[0-9]+\.[0-9]+\.[0-9]+\+Branch.support-5.x.Sha.[0-9a-z]+'

    assert_success
}

# bats test_tags=target,gitversion-release
@test "Makester versioning release version" {
    MAKESTER__GITVERSION_CONFIG=sample/GitVersion.yml run make -f makefiles/makester.mk gitversion-release

    assert_output --regexp "### Filtering GitVersion variable: AssemblySemFileVer
### Removing $MAKESTER__WORK_DIR/versioning
### Creating Makester working directory \"$MAKESTER__WORK_DIR\"
### MAKESTER__RELEASE_VERSION: [0-9]+\.[0-9]+\.[0-9]+[ab]{0,1}[0-9]{0,3}"

    assert_success
}
# bats test_tags=target,gitversion-release
@test "Makester versioning release version with overridden version variable" {
    MAKESTER__GITVERSION_CONFIG=sample/GitVersion.yml MAKESTER__GITVERSION_VARIABLE=ShortSha\
 run make -f makefiles/makester.mk gitversion-release

    assert_output --regexp "### Filtering GitVersion variable: ShortSha
### Removing $MAKESTER__WORK_DIR/versioning
### Creating Makester working directory \"$MAKESTER__WORK_DIR\"
### MAKESTER__RELEASE_VERSION: [0-9a-z]{0,7}"

    assert_success
}

# bats test_tags=target,gitversion-release-ro
@test "Makester versioning release version read only" {
    MAKESTER__GITVERSION_CONFIG=sample/GitVersion.yml run make -f makefiles/makester.mk gitversion-release-ro

    assert_output --regexp "### Filtering GitVersion variable: AssemblySemFileVer
### Removing $MAKESTER__WORK_DIR/versioning
### Creating Makester working directory \"$MAKESTER__WORK_DIR\"
### MAKESTER__RELEASE_VERSION: [0-9]+\.[0-9]+\.[0-9]+[ab]{0,1}[0-9]{0,3}"

    assert_success
}
# bats test_tags=target,gitversion-release-ro
@test "Makester versioning release version with overridden version variable read only" {
    MAKESTER__GITVERSION_CONFIG=sample/GitVersion.yml MAKESTER__GITVERSION_VARIABLE=ShortSha\
 run make -f makefiles/makester.mk gitversion-release-ro

    assert_output --regexp "### Filtering GitVersion variable: ShortSha
### Removing $MAKESTER__WORK_DIR/versioning
### Creating Makester working directory \"$MAKESTER__WORK_DIR\"
### MAKESTER__RELEASE_VERSION: [0-9a-z]{0,7}"

    assert_success
}

# bats test_tags=target,gitversion-clear,dry-run
@test "Makester versioning clear dynamic version output: dry" {
    run make -f makefiles/makester.mk gitversion-clear --dry-run

    assert_output "### Removing $MAKESTER__WORK_DIR/VERSION
### Removing $MAKESTER__WORK_DIR/versioning"

    assert_success
}
# bats test_tags=target,gitversion-clear,dry-run
@test "Makester versioning clear dynamic version output override MAKESTER__VERSION_FILE: dry" {
    MAKESTER__VERSION_FILE=/tmp/VERSION run make -f makefiles/makester.mk gitversion-clear --dry-run

    assert_output "### Removing /tmp/VERSION
### Removing $MAKESTER__WORK_DIR/versioning"

    assert_success
}
