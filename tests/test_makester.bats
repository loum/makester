# Test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats tests
#
setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
}

# Makester variables.
#
# MAKESTER__PRIMED
@test "MAKESTER__PRIMED should be set when calling makester.mk" {
    result="$(make -f makefiles/makester.mk print-MAKESTER__PRIMED)"
    [ "$result" = "MAKESTER__PRIMED=true" ]
}

# MAKESTER__LOCAL_IP
@test "Override MAKESTER__LOCAL_IP" {
    result="$(MAKESTER__LOCAL_IP=127.0.0.1 make -f makefiles/makester.mk print-MAKESTER__LOCAL_IP)"
    [ "$result" = "MAKESTER__LOCAL_IP=127.0.0.1" ]
}

# Makester dependency checkers.
#
# Environment variable checker
@test "which-var \"BANANA\" is undefined" {
    MAKESTER__VAR=BANANA MAKESTER__VAR_INFO="Just an error message ..." run make -f makefiles/makester.mk which-var
    assert_output --partial '### Checking if "BANANA" is defined ...
### "BANANA" undefined
### Just an error message ...'
    [ "$status" -eq 2 ]
}

@test "which-var \"MAKESTER__PROJECT_NAME\" is defined" {
    MAKESTER__VAR=MAKESTER__PROJECT_NAME run make -f makefiles/makester.mk which-var
    assert_output --partial '### Checking if "MAKESTER__PROJECT_NAME" is defined ...'
    [ "$status" -eq 0 ]
}

# Executable checker.
@test "check-exe rule for \"GIT\" finds the executable" {
    run make -f makefiles/makester.mk print-GIT
    assert_output --regexp 'GIT=.*/git'
    [ "$status" -eq 0 ]
}
