# Python test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags _py-proj tests
#
# bats file_tags=_py-proj
setup_file() {
    MAKESTER__PROJECT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/makester-XXXXXX")
    export MAKESTER__PROJECT_DIR
}
setup() {
    unset MAKESTER__SYSTEM_PYTHON3
    load 'test_helper/common-setup'
    _common_setup
}
teardown_file() {
    MAKESTER__PYTHON_PROJECT_ROOT=$MAKESTER__PROJECT_DIR make py-proj-toml-rm
    MAKESTER__PYTHON_PROJECT_ROOT=$MAKESTER__PROJECT_DIR make py-proj-cli-rm
    rmdir "$MAKESTER__PROJECT_DIR"
}


# Python project variables.
#
# bats test_tags=variables,py-variables,MAKESTER__PYPROJECT_TOML
@test "MAKESTER__PROJECT_TOML default should be set when calling py.mk" {
    MAKESTER__PROJECT_DIR=$MAKESTER__PROJECT_DIR run make -f makefiles/makester.mk print-MAKESTER__PYPROJECT_TOML

    assert_output "MAKESTER__PYPROJECT_TOML=$MAKESTER__PROJECT_DIR/pyproject.toml"

    assert_success
}
# bats test_tags=variables,py-variables,MAKESTER__PYPROJECT_TOML
@test "MAKESTER__PROJECT_TOML override" {
    MAKESTER__PYPROJECT_TOML="test"\
 run make -f makefiles/makester.mk print-MAKESTER__PYPROJECT_TOML

    assert_output 'MAKESTER__PYPROJECT_TOML=test'

    assert_success
}

# Targets.
#
# bats test_tags=target,py-proj-create,dry-run
@test "Python project scaffolding: dry" {
    MAKESTER__RESOURCES_DIR=resources MAKESTER__PROJECT_DIR=/var/tmp/fruit MAKESTER__PACKAGE_NAME=banana\
 run make -f makefiles/makester.mk py-proj-create --dry-run

    assert_output --regexp "### Writing pyproject.toml to \"/var/tmp/fruit/pyproject.toml\" ...
eval \"\\\$_pyproject_toml_script\"
### Creating a Python project directory structure under /var/tmp/fruit/src/banana
/.*/mkdir -pv /var/tmp/fruit/src/banana
/.*/touch /var/tmp/fruit/src/banana/__init__.py
/.*/mkdir -pv /var/tmp/fruit/tests/banana
/.*/cp resources/blank_directory.gitignore /var/tmp/fruit/tests/banana/.gitignore"

    assert_success
}

# bats test_tags=target,py-proj-toml-create
@test "Python project.toml primer" {
    MAKESTER__PYPROJECT_TOML=$MAKESTER__PROJECT_DIR/pyproject.toml \
 run make -f makefiles/makester.mk py-proj-toml-create
    diff "$MAKESTER__PROJECT_DIR"/pyproject.toml tests/files/out/py/default-pyproject.toml

    assert_output "### Writing pyproject.toml to \"$MAKESTER__PROJECT_DIR/pyproject.toml\" ..."

    assert_success
}
# bats test_tags=target,py-proj-toml-create
@test "Python pyproject.toml primer MAKESTER__PACKAGE_NAME override" {
    MAKESTER__PYPROJECT_TOML=$MAKESTER__PROJECT_DIR/pyproject.toml MAKESTER__PACKAGE_NAME=banana\
 run make -f makefiles/makester.mk py-proj-toml-create
    diff "$MAKESTER__PROJECT_DIR"/pyproject.toml tests/files/out/py/package-name-override-pyproject.toml

    assert_output "### Writing pyproject.toml to \"$MAKESTER__PROJECT_DIR/pyproject.toml\" ..."

    assert_success
}

# bats test_tags=target,py-proj-cli
@test "Python CLI __init__ primer" {
    MAKESTER__PYTHON_PROJECT_ROOT="$MAKESTER__PROJECT_DIR" \
 run make -f makefiles/makester.mk _py-cli-init
    diff "$MAKESTER__PROJECT_DIR/__init__.py" tests/files/out/py/cli-init.py

    assert_output "### Writing CLI __init__.py scaffolding under \"$MAKESTER__PROJECT_DIR\" ..."

    assert_success
}

# bats test_tags=target,py-proj-cli
@test "Python CLI __main__ primer" {
    MAKESTER__PYTHON_PROJECT_ROOT="$MAKESTER__PROJECT_DIR" \
 run make -f makefiles/makester.mk _py-cli-main
    diff "$MAKESTER__PROJECT_DIR/__main__.py" tests/files/out/py/cli-main.py

    assert_output "### Writing CLI __main__.py scaffolding under \"$MAKESTER__PROJECT_DIR\" ..."

    assert_success
}
