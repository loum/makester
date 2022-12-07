# Docker test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags python-venv tests
#
# bats file_tags=python-venv
setup() {
    load 'test_helper/common-setup'
    _common_setup
}

# Docker include dependencies.
#
# Makester.
# bats test_tags=python-venv-dependencies
@test "Check if Makester is primed: false" {
    run make -f makefiles/docker.mk
    assert_output --partial '### Add the following include statement to your Makefile
include makester/makefiles/makester.mk'
    [ "$status" -eq 2 ]
}
# bats test_tags=python-venv-dependencies
@test "Check if Makester is primed: true" {
    run make -f makefiles/makester.mk -f makefiles/docker.mk docker-help
    assert_output --partial '(makefiles/docker.mk)'
    [ "$status" -eq 0 ]
}

# Python venv variables.
#
# MAKESTER__WHEEL
# bats test_tags=variables,python-venv-variables,MAKESTER__WHEEL
@test "MAKESTER__WHEEL default should be set when calling python-venv.mk" {
    run make -f makefiles/makester.mk -f makefiles/python-venv.mk print-MAKESTER__WHEEL
    assert_output 'MAKESTER__WHEEL=~/wheelhouse'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,python-venv-variables,MAKESTER__WHEEL
@test "MAKESTER__WHEEL override" {
    MAKESTER__WHEEL=~/.wheelhouse\
 run make -f makefiles/makester.mk -f makefiles/python-venv.mk print-MAKESTER__WHEEL
    assert_output --regexp 'MAKESTER__WHEEL=.*/\.wheelhouse'
    [ "$status" -eq 0 ]
}

# PYTHONPATH
# bats test_tags=variables,python-venv-variables,PYTHONPATH
@test "PYTHONPATH default should be set when calling python-venv.mk" {
    run make -f makefiles/makester.mk -f makefiles/python-venv.mk print-PYTHONPATH
    assert_output 'PYTHONPATH=src'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,python-venv-variables,PYTHONPATH
@test "PYTHONPATH override" {
    PYTHONPATH=. run make -f makefiles/makester.mk -f makefiles/python-venv.mk print-PYTHONPATH
    assert_output --regexp 'PYTHONPATH=.'
    [ "$status" -eq 0 ]
}

# Symbol deprecation.
# bats test_tags=deprecated
@test "Warning for deprecated symbol PYTHON" {
    run make -f makefiles/makester.mk -f makefiles/python-venv.mk print-PYTHON
    assert_output --partial '### "PYTHON" will be deprecated in Makester: 0.2.0
### Replace "PYTHON" with "MAKESTER__PYTHON"'
    [ "$status" -eq 2 ]
}

# Symbol deprecation.
# bats test_tags=deprecated
@test "Warning for deprecated symbol WHEEL" {
    run make -f makefiles/makester.mk -f makefiles/python-venv.mk print-WHEEL
    assert_output --partial '### "WHEEL" will be deprecated in Makester: 0.2.0
### Replace "WHEEL" with "MAKESTER__WHEEL"'
    [ "$status" -eq 2 ]
}

# Symbol deprecation.
# bats test_tags=deprecated
@test "Warning for deprecated symbol PIP" {
    run make -f makefiles/makester.mk -f makefiles/python-venv.mk print-PIP
    assert_output --partial '### "PIP" will be deprecated in Makester: 0.2.0
### Replace "PIP" with "MAKESTER__PIP"'
    [ "$status" -eq 2 ]
}
