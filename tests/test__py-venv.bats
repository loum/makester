# Python venv test runner (called through makefiles/py.mk).
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags _py-venv tests
#
# bats file_tags=_py-venv
setup_file() {
    MAKESTER__PROJECT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/makester-XXXXXX")
    export MAKESTER__PROJECT_DIR
}
setup() {
    load 'test_helper/common-setup'
    _common_setup
}
teardown_file() {
    rmdir "$MAKESTER__PROJECT_DIR"
}

# Python venv variables.
#
# MAKESTER__PIP
# bats test_tags=variables,_py-venv-variables,MAKESTER__PIP
@test "MAKESTER__PIP default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PIP

    assert_output --regexp 'MAKESTER__PIP=.*/venv/bin/pip'

    assert_success
}
# bats test_tags=variables,_py-venv-variables,MAKESTER__PIP
@test "MAKESTER__PIP override" {
    MAKESTER__PIP=dummy/bin/pip run make -f makefiles/makester.mk print-MAKESTER__PIP

    assert_output 'MAKESTER__PIP=dummy/bin/pip'

    assert_success
}

# MAKESTER__PYTHON
# bats test_tags=variables,_py-venv-variables,MAKESTER__PYTHON
@test "MAKESTER__PYTHON default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PYTHON

    assert_output --regexp 'MAKESTER__PYTHON=.*/venv/bin/python'

    assert_success
}
# bats test_tags=variables,_py-venv-variables,MAKESTER__PYTHON
@test "MAKESTER__PYTHON override" {
    MAKESTER__PYTHON=dummy/bin/python run make -f makefiles/makester.mk print-MAKESTER__PYTHON

    assert_output 'MAKESTER__PYTHON=dummy/bin/python'

    assert_success
}

# MAKESTER__VENV_HOME
# bats test_tags=variables,_py-venv-variables,MAKESTER__VENV_HOME
@test "MAKESTER__VENV_HOME default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__VENV_HOME

    assert_output --regexp 'MAKESTER__VENV_HOME=.*/venv'

    assert_success
}
# bats test_tags=variables,_py-venv-variables,MAKESTER__VENV_HOME
@test "MAKESTER__VENV_HOME override" {
    MAKESTER__VENV_HOME=/tmp/dummy/venv run make -f makefiles/makester.mk print-MAKESTER__VENV_HOME

    assert_output 'MAKESTER__VENV_HOME=/tmp/dummy/venv'

    assert_success
}
# bats test_tags=variables,_py-venv-variables,MAKESTER__VENV_HOME
@test "MAKESTER__VENV_HOME with MAKESTER__PROJECT_DIR override" {
    MAKESTER__PROJECT_DIR=/tmp/dummy run make -f makefiles/makester.mk print-MAKESTER__VENV_HOME

    assert_output 'MAKESTER__VENV_HOME=/tmp/dummy/venv'

    assert_success
}

# Targets.
#
# bats test_tags=target,py-venv-create,dry
@test "Python virtual environment create: dry" {
    run make -f makefiles/makester.mk py-venv-create --dry-run

    assert_output --regexp "### Creating virtual environment .*/venv ..."

    assert_success
}

# bats test_tags=target,py-venv-clear,dry
@test "Python virtual environment delete: dry" {
    _VENV_DIR_EXISTS=1 run make -f makefiles/makester.mk py-venv-clear --dry-run

    assert_output --regexp "### Deleting virtual environment .*/venv ..."

    assert_success
}

# bats test_tags=target,pip-editable,dry
@test "Python setup.py editable install: dry" {
    run make -f makefiles/makester.mk pip-editable --dry-run

    assert_output --regexp '### Installing project dependencies into /.*/venv ...
/.*/venv/bin/pip install --find-links=~/wheelhouse -e .'

    assert_success
}
# bats test_tags=target,pip-editable,dry
@test "Python setup.py editable install MAKESTER__PIP_INSTALL override: dry" {
    MAKESTER__PIP_INSTALL="-e .[extra]" run make -f makefiles/makester.mk pip-editable --dry-run

    assert_output --regexp '### Installing project dependencies into /.*/venv ...
/.*/venv/bin/pip install --find-links=~/wheelhouse -e \.\[extra\]'

    assert_success
}

# Symbol deprecation.
#
# bats test_tags=deprecated
@test "Warning for deprecated symbol target py-versions" {
    run make -f makefiles/makester.mk py-versions

    assert_output --partial '### "py-versions" will be deprecated in Makester: 0.3.0
### Replace "py-versions" with "py-venv-vars"'

    assert_success
}

# bats test_tags=deprecated
@test "Warning for deprecated symbol target clear-env" {
    run make -f makefiles/makester.mk clear-env --dry-run

    assert_output --partial '### "clear-env" will be deprecated in Makester: 0.3.0
### Replace "clear-env" with "py-venv-clear"'

    assert_success
}

# bats test_tags=deprecated
@test "Warning for deprecated symbol target init-env" {
    run make -f makefiles/makester.mk init-env --dry-run

    assert_output --partial '### "init-env" will be deprecated in Makester: 0.3.0
### Replace "init-env" with "py-venv-init"'

    assert_success
}
