# Test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats tests
#
setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    export MAKESTER__WORK_DIR=$(mktemp -d -t makester-XXXXXX)
}

teardown() {
    rmdir $MAKESTER__WORK_DIR
}


# Makester variables.
#
# MAKESTER__PRIMED
# bats test_tags=MAKESTER__PRIMED
@test "MAKESTER__PRIMED should be set when calling makester.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PRIMED
    assert_output 'MAKESTER__PRIMED=true'
    [ "$status" -eq 0 ]
}

# MAKESTER__LOCAL_IP
# bats test_tags=MAKESTER__LOCAL_IP
@test "Override MAKESTER__LOCAL_IP override" {
    MAKESTER__LOCAL_IP=127.0.0.1 run make -f makefiles/makester.mk print-MAKESTER__LOCAL_IP
    assert_output 'MAKESTER__LOCAL_IP=127.0.0.1'
    [ "$status" -eq 0 ]
}

# bats test_tags=MAKESTER__RELEASE_VERSION
@test "MAKESTER__RELEASE_VERSION defaults to HASH" {
    run make -f makefiles/makester.mk print-MAKESTER__RELEASE_VERSION
    assert_output 'MAKESTER__RELEASE_VERSION=<undefined>'
    [ "$status" -eq 0 ]
}
# bats test_tags=MAKESTER__RELEASE_VERSION
@test "MAKESTER__RELEASE_VERSION override" {
    MAKESTER__RELEASE_VERSION=override run make -f makefiles/makester.mk print-MAKESTER__RELEASE_VERSION
    assert_output --regexp '^MAKESTER__RELEASE_VERSION=override$'
    [ "$status" -eq 0 ]
}

# Makester dependency checkers.
#
# Environment variable checker
# bats test_tags=which-var
@test "which-var \"BANANA\" is undefined" {
    MAKESTER__VAR=BANANA MAKESTER__VAR_INFO="Just an error message ..." run make -f makefiles/makester.mk which-var
    assert_output --partial '### Checking if "BANANA" is defined ...
### "BANANA" undefined
### Just an error message ...'
    [ "$status" -eq 2 ]
}

# bats test_tags=which-var
@test "which-var \"MAKESTER__PROJECT_NAME\" is defined" {
    MAKESTER__VAR=MAKESTER__PROJECT_NAME run make -f makefiles/makester.mk which-var
    assert_output --partial '### Checking if "MAKESTER__PROJECT_NAME" is defined ...'
    [ "$status" -eq 0 ]
}

# bats test_tags=which-var
@test "which-var \"MAKESTER__WORK_DIR\" is defined" {
    MAKESTER__VAR=MAKESTER__WORK_DIR run make -f makefiles/makester.mk which-var
    assert_output --partial '### Checking if "MAKESTER__WORK_DIR" is defined ...'
    [ "$status" -eq 0 ]
}

# Executable checker.
# bats test_tags=check-exe
@test "check-exe rule for \"GIT\" finds the executable" {
    run make -f makefiles/makester.mk print-GIT
    assert_output --regexp 'GIT=.*/git'
    [ "$status" -eq 0 ]
}
