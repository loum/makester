# Python test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags py tests
#
# bats file_tags=py
setup() {
    load 'test_helper/common-setup'
    _common_setup
}

# Python include dependencies.
#
# Makester.
# bats test_tags=py-dependencies
@test "Check if Makester is primed: false" {
    run make -f makefiles/py.mk
    assert_output --partial '### Add the following include statement to your Makefile
include makester/makefiles/makester.mk'
    [ "$status" -eq 2 ]
}
# bats test_tags=py-dependencies
@test "Check if Makester is primed: true" {
    run make -f makefiles/makester.mk -f makefiles/py.mk py-help
    assert_output --partial '(makefiles/py.mk)'
    [ "$status" -eq 0 ]
}

# Python variables.
#
# PYTHONPATH
# bats test_tags=variables,py-variables,PYTHONPATH
@test "PYTHONPATH default should be set when calling py.mk" {
    run make -f makefiles/makester.mk -f makefiles/py.mk print-PYTHONPATH
    assert_output 'PYTHONPATH=src'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,py-variables,PYTHONPATH
@test "PYTHONPATH override" {
    PYTHONPATH=. run make -f makefiles/makester.mk -f makefiles/py.mk print-PYTHONPATH
    assert_output --regexp 'PYTHONPATH=.'
    [ "$status" -eq 0 ]
}

# MAKESTER__SYSTEM_PYTHON3
# bats test_tags=variables,py-variables,MAKESTER__SYSTEM_PYTHON3
@test "MAKESTER__SYSTEM_PYTHON3 default should be set when calling py.mk" {
    run make -f makefiles/makester.mk -f makefiles/py.mk print-MAKESTER__SYSTEM_PYTHON3
    assert_output --regexp 'MAKESTER__SYSTEM_PYTHON3=.*/python3'
    # We don't want the virtual enviornment Python here.
    refute_output --regexp 'MAKESTER__SYSTEM_PYTHON3=.*/3env'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,py-variables,MAKESTER__SYSTEM_PYTHON3
@test "MAKESTER__SYSTEM_PYTHON3 override" {
    MAKESTER__SYSTEM_PYTHON3=/usr/local/bin/banana\
 run make -f makefiles/makester.mk -f makefiles/py.mk print-MAKESTER__SYSTEM_PYTHON3
    assert_output --regexp "makefiles/py.mk:[0-9]{1,5}:\
 \*\*\* ### No Python executable found: Check your MAKESTER__SYSTEM_PYTHON3=/usr/local/bin/banana setting.  Stop."
    [ "$status" -eq 2 ]
}

# bats test_tags=variables,py-variables,MAKESTER__PY3_VERSION
@test "MAKESTER__PY3_VERSION default should be set when calling py.mk" {
    run make -f makefiles/makester.mk -f makefiles/py.mk print-MAKESTER__PY3_VERSION
    assert_output --regexp 'MAKESTER__PY3_VERSION=Python 3\.[0-9]{1,2}\.[0-9]{1,2}'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,py-variables,MAKESTER__PY3_VERSION
@test "MAKESTER__PY3_VERSION override" {
    MAKESTER__PY3_VERSION="Python 3.9.13"\
 run make -f makefiles/makester.mk -f makefiles/py.mk print-MAKESTER__PY3_VERSION
    assert_output 'MAKESTER__PY3_VERSION=Python 3.9.13'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,py-variables-private,_PY3_VERSION_FULL
@test "_PY3_VERSION_FULL default should be set when calling py.mk" {
    run make -f makefiles/makester.mk -f makefiles/py.mk print-_PY3_VERSION_FULL
    assert_output --regexp '_PY3_VERSION_FULL=3 [0-9]{1,2} [0-9]{1,2}'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,py-variables-private,_PY3_VERSION_FULL
@test "_PY3_VERSION_FULL override" {
    MAKESTER__PY3_VERSION="Python 3.9.13"\
 run make -f makefiles/makester.mk -f makefiles/py.mk print-_PY3_VERSION_FULL
    assert_output '_PY3_VERSION_FULL=3 9 13'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,py-variables,MAKESTER__WHEEL
@test "MAKESTER__WHEEL default should be set when calling py.mk" {
    run make -f makefiles/makester.mk -f makefiles/py.mk print-MAKESTER__WHEEL
    assert_output 'MAKESTER__WHEEL=~/wheelhouse'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,py-variables,MAKESTER__WHEEL
@test "MAKESTER__WHEEL override" {
    MAKESTER__WHEEL=~/.wheelhouse\
 run make -f makefiles/makester.mk -f makefiles/py.mk print-MAKESTER__WHEEL
    assert_output --regexp 'MAKESTER__WHEEL=.*/\.wheelhouse'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,py-variables,MAKESTER__PIP_INSTALL
@test "MAKESTER__PIP_INSTALL default should be set when calling py.mk" {
    run make -f makefiles/makester.mk -f makefiles/py.mk print-MAKESTER__PIP_INSTALL
    assert_output 'MAKESTER__PIP_INSTALL=-e .'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,py-variables,MAKESTER__PIP_INSTALL
@test "MAKESTER__PIP_INSTALL override" {
    MAKESTER__PIP_INSTALL=makester\
 run make -f makefiles/makester.mk -f makefiles/py.mk print-MAKESTER__PIP_INSTALL
    assert_output --regexp 'MAKESTER__PIP_INSTALL=makester'
    [ "$status" -eq 0 ]
}

# Targets.
#
# bats test_tags=py-vars
@test "Python system variables" {
    run make -f makefiles/makester.mk -f makefiles/py.mk py-vars
    refute_output --regexp '### System python3: .*/3env/.*/python3'
    [ "$status" -eq 0 ]
}

# bats test_tags=py-install
@test "Python package install: dry" {
    run make -f makefiles/makester.mk -f makefiles/py.mk py-install --dry-run
    assert_output --regexp '### Installing project dependencies into .*/venv ...
.*/venv/bin/pip install --find-links=~/wheelhouse -e .'
    [ "$status" -eq 0 ]
}
# bats test_tags=py-install
@test "Python package install MAKESTER__WHEEL override: dry" {
    MAKESTER__WHEEL=.wheelhouse\
 run make -f makefiles/makester.mk -f makefiles/py.mk py-install --dry-run
    assert_output --regexp '### Installing project dependencies into .*/venv ...
.*/venv/bin/pip install --find-links=.wheelhouse -e \.'
    [ "$status" -eq 0 ]
}

# bats test_tags=py-install-makester
@test "Python package install MAKESTER__PIP_INSTALL override: dry" {
    _VENV_DIR_EXISTS=1 run make -f makefiles/makester.mk -f makefiles/py.mk py-install-makester --dry-run
    assert_output --regexp '### Deleting virtual environment .*/venv ...
.*/rm -fr .*/venv
### Creating Wheel directory "~/wheelhouse"...
.*/mkdir -pv ~/wheelhouse
### Creating virtual environment .*/venv ...
### Preparing pip and setuptools ...
.*/python3 -m venv .*/venv
.*/venv/bin/pip install --upgrade pip setuptools wheel
### Installing project packages into .*/venv ...
.*/venv/bin/pip install --find-links=~/wheelhouse -e makester
### Installing project dependencies into .*/venv ...
.*/venv/bin/pip install --find-links=~/wheelhouse -e makester'
    [ "$status" -eq 0 ]
}
