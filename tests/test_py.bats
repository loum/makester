# Python test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags py tests
#
# bats file_tags=py
setup_file() {
    export MAKESTER__PROJECT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/makester-XXXXXX")
}
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
    run make -f makefiles/makester.mk py-help
    assert_output --partial '(makefiles/py.mk)'
    [ "$status" -eq 0 ]
}

# Python variables.
#
# PYTHONPATH
# bats test_tags=variables,py-variables,PYTHONPATH
@test "PYTHONPATH default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-PYTHONPATH
    assert_output "PYTHONPATH=$MAKESTER__PROJECT_DIR/src"
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,py-variables,PYTHONPATH
@test "PYTHONPATH override" {
    PYTHONPATH=. run make -f makefiles/makester.mk print-PYTHONPATH
    assert_output --regexp 'PYTHONPATH=.'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,py-variables,MAKESTER__PYTHONPATH
@test "MAKESTER__PYTHONPATH default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PYTHONPATH
    assert_output "MAKESTER__PYTHONPATH=$MAKESTER__PROJECT_DIR/src"
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,py-variables,MAKESTER__PYTHONPATH
@test "MAKESTER__PYTHONPATH override" {
    MAKESTER__PYTHONPATH=something_else run make -f makefiles/makester.mk print-MAKESTER__PYTHONPATH
    assert_output "MAKESTER__PYTHONPATH=something_else"
    [ "$status" -eq 0 ]
}

# MAKESTER__SYSTEM_PYTHON3
# bats test_tags=variables,py-variables,MAKESTER__SYSTEM_PYTHON3
@test "MAKESTER__SYSTEM_PYTHON3 default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__SYSTEM_PYTHON3
    assert_output --regexp 'MAKESTER__SYSTEM_PYTHON3=.*/python3'
    # We don't want the virtual enviornment Python here.
    refute_output --regexp 'MAKESTER__SYSTEM_PYTHON3=.*/3env'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,py-variables,MAKESTER__SYSTEM_PYTHON3
@test "MAKESTER__SYSTEM_PYTHON3 override" {
    MAKESTER__SYSTEM_PYTHON3=/usr/local/bin/banana\
 run make -f makefiles/makester.mk print-MAKESTER__SYSTEM_PYTHON3
    assert_output --regexp "makefiles/py.mk:[0-9]{1,5}:\
 \*\*\* ### No Python executable found: Check your MAKESTER__SYSTEM_PYTHON3=/usr/local/bin/banana setting.  Stop."
    [ "$status" -eq 2 ]
}

# bats test_tags=variables,py-variables,MAKESTER__PY3_VERSION
@test "MAKESTER__PY3_VERSION default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PY3_VERSION
    assert_output --regexp 'MAKESTER__PY3_VERSION=Python 3\.[0-9]{1,2}\.[0-9]{1,2}'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,py-variables,MAKESTER__PY3_VERSION
@test "MAKESTER__PY3_VERSION override" {
    MAKESTER__PY3_VERSION="Python 3.9.13"\
 run make -f makefiles/makester.mk print-MAKESTER__PY3_VERSION
    assert_output 'MAKESTER__PY3_VERSION=Python 3.9.13'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,py-variables-private,_PY3_VERSION_FULL
@test "_PY3_VERSION_FULL default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-_PY3_VERSION_FULL
    assert_output --regexp '_PY3_VERSION_FULL=3 [0-9]{1,2} [0-9]{1,2}'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,py-variables-private,_PY3_VERSION_FULL
@test "_PY3_VERSION_FULL override" {
    MAKESTER__PY3_VERSION="Python 3.9.13"\
 run make -f makefiles/makester.mk print-_PY3_VERSION_FULL
    assert_output '_PY3_VERSION_FULL=3 9 13'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,py-variables,MAKESTER__WHEEL
@test "MAKESTER__WHEEL default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__WHEEL
    assert_output 'MAKESTER__WHEEL=~/wheelhouse'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,py-variables,MAKESTER__WHEEL
@test "MAKESTER__WHEEL override" {
    MAKESTER__WHEEL=~/.wheelhouse\
 run make -f makefiles/makester.mk print-MAKESTER__WHEEL
    assert_output --regexp 'MAKESTER__WHEEL=.*/\.wheelhouse'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,py-variables,MAKESTER__PIP_INSTALL
@test "MAKESTER__PIP_INSTALL default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PIP_INSTALL
    assert_output 'MAKESTER__PIP_INSTALL=-e .'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,py-variables,MAKESTER__PIP_INSTALL
@test "MAKESTER__PIP_INSTALL override" {
    MAKESTER__PIP_INSTALL=makester\
 run make -f makefiles/makester.mk print-MAKESTER__PIP_INSTALL
    assert_output --regexp 'MAKESTER__PIP_INSTALL=makester'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,py-variables,MAKESTER__PYLINT_RCFILE
@test "MAKESTER__PYLINT_RCFILE default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PYLINT_RCFILE
    assert_output --regexp 'MAKESTER__PYLINT_RCFILE=.*/pylintrc'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,py-variables,MAKESTER__PYLINT_RCFILE
@test "MAKESTER__PYLINT_RCFILE override" {
    MAKESTER__PYLINT_RCFILE=pylintrc\
 run make -f makefiles/makester.mk print-MAKESTER__PYLINT_RCFILE
    assert_output 'MAKESTER__PYLINT_RCFILE=pylintrc'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,py-variables,MAKESTER__PIP_INSTALL_EXTRAS
@test "MAKESTER__PIP_INSTALL_EXTRAS default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PIP_INSTALL_EXTRAS
    assert_output 'MAKESTER__PIP_INSTALL_EXTRAS=dev'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,py-variables,MAKESTER__PIP_INSTALL_EXTRAS
@test "MAKESTER__PIP_INSTALL_EXTRAS override" {
    MAKESTER__PIP_INSTALL_EXTRAS=test\
 run make -f makefiles/makester.mk print-MAKESTER__PIP_INSTALL_EXTRAS
    assert_output 'MAKESTER__PIP_INSTALL_EXTRAS=test'
    [ "$status" -eq 0 ]
}

# Targets.
#
# bats test_tags=target,py-vars
@test "Python system variables" {
    run make -f makefiles/makester.mk py-vars
    refute_output --regexp '### System python3: .*/3env/.*/python3'
    [ "$status" -eq 0 ]
}

# bats test_tags=target,py-install,dry-run
@test "Python package install: dry" {
    run make -f makefiles/makester.mk py-install --dry-run
    assert_output --regexp '### Installing project dependencies into .*/venv ...
.*/venv/bin/pip install --find-links=~/wheelhouse -e .'
    [ "$status" -eq 0 ]
}
# bats test_tags=target,py-install,dry-run
@test "Python package install MAKESTER__WHEEL override: dry" {
    MAKESTER__WHEEL=.wheelhouse\
 run make -f makefiles/makester.mk py-install --dry-run
    assert_output --regexp '### Installing project dependencies into .*/venv ...
.*/venv/bin/pip install --find-links=.wheelhouse -e \.'
    [ "$status" -eq 0 ]
}

# bats test_tags=target,py-install-extras,dry-run
@test "Python package extras install: dry" {
    run make -f makefiles/makester.mk py-install-extras --dry-run
    assert_output --regexp '### Installing project dependencies into .*/venv ...
.*/venv/bin/pip install --find-links=~/wheelhouse -e \.\[dev\]'
    [ "$status" -eq 0 ]
}
# bats test_tags=target,py-install-extras,dry-run
@test "Python package extras install +MAKESTER__PIP_INSTALL_EXTRAS override: dry" {
    MAKESTER__PIP_INSTALL_EXTRAS=test\
 run make -f makefiles/makester.mk py-install-extras --dry-run
    assert_output --regexp '### Installing project dependencies into .*/venv ...
.*/venv/bin/pip install --find-links=~/wheelhouse -e \.\[test\]'
    [ "$status" -eq 0 ]
}

# bats test_tags=target,py-install-makester,dry-run
@test "Python package install MAKESTER__PIP_INSTALL override: dry" {
    _VENV_DIR_EXISTS=1 run make -f makefiles/makester.mk py-install-makester --dry-run
    assert_output --regexp '### Installing project dependencies into .*/venv ...
.*/venv/bin/pip install --find-links=~/wheelhouse -e makester'
    [ "$status" -eq 0 ]
}

# bats test_tags=target,py-pylintrc,dry-run
@test "Python pylint configuration generator: dry" {
    run make -f makefiles/makester.mk py-pylintrc --dry-run
    assert_output --regexp 'pylint --generate-rcfile > /.*/pylintrc'
    [ "$status" -eq 0 ]
}
# bats test_tags=target,py-pylintrc,dry-run
@test "Python pylint configuration generator MAKESTER__PYLINT_RCFILE override: dry" {
    MAKESTER__PYLINT_RCFILE=pylintrc run make -f makefiles/makester.mk py-pylintrc --dry-run
    assert_output --regexp 'pylint --generate-rcfile > pylintrc'
    [ "$status" -eq 0 ]
}

# bats test_tags=target,py-project-create,dry-run
@test "Python project scaffolding: dry" {
    MAKESTER__RESOURCES_DIR=resources MAKESTER__PROJECT_DIR=/var/tmp/fruit MAKESTER__PACKAGE_NAME=banana\
 run make -f makefiles/makester.mk py-project-create --dry-run
    assert_output --regexp '### Adding a sane .gitignore to "/var/tmp/fruit"
/.*/cp resources/project.gitignore /var/tmp/fruit/.gitignore
### Adding MIT license to "/var/tmp/fruit"
/.*/cp resources/mit.md /var/tmp/fruit/LICENSE.md
### Creating a Python project directory structure under /var/tmp/fruit/src/banana
/.*/mkdir -pv /var/tmp/fruit/src/banana
/.*/touch /var/tmp/fruit/src/banana/__init__.py
/.*/mkdir -pv /var/tmp/fruit/tests/banana
/.*/cp resources/blank_directory.gitignore /var/tmp/fruit/tests/banana/.gitignore
/.*/cp resources/pyproject.toml /var/tmp/fruit'
    [ "$status" -eq 0 ]
}

# bats test_tags=target,py-deps,dry-run
@test "Python project package dependency dump" {
    run make -f makefiles/makester.mk py-deps --dry-run
    assert_output '### Displaying "makefiles" package dependencies ...
pipdeptree'
    [ "$status" -eq 0 ]
}

# bats test_tags=target,py-fmt-all,dry-run
@test "Python module formatter for all under MAKESTER__PROJECTPATH: dry" {
    run make -f makefiles/makester.mk py-fmt-all --dry-run
    assert_output --regexp "black $MAKESTER__PROJECT_DIR/src"
    [ "$status" -eq 0 ]
}
# bats test_tags=target,py-fmt-all,dry-run
@test "Python module formatter for all MAKESTER__PYTHONPATH override: dry" {
    MAKESTER__PYTHONPATH=something_else run make -f makefiles/makester.mk py-fmt-all --dry-run
    assert_output --regexp "black something_else"
    [ "$status" -eq 0 ]
}

# bats test_tags=target,py-fmt,dry-run
@test "Python module formatter FMT_PATH undefined: dry" {
    run make -f makefiles/makester.mk py-fmt --dry-run
    assert_output --partial '### "FMT_PATH" undefined'
    [ "$status" -eq 2 ]
}
# bats test_tags=target,py-fmt,dry-run
@test "Python module formatter FMT_PATH set: dry" {
    FMT_PATH=src/makester run make -f makefiles/makester.mk py-fmt --dry-run
    assert_output '### Formatting Python files under "src/makester"
black src/makester'
    [ "$status" -eq 0 ]
}

# bats test_tags=target,py-lint-all,dry-run
@test "Python module linter for all under MAKESTER__PROJECTPATH: dry" {
    run make -f makefiles/makester.mk py-lint-all --dry-run
    assert_output --regexp "pylint $MAKESTER__PROJECT_DIR/src"
    [ "$status" -eq 0 ]
}
# bats test_tags=target,py-lint-all,dry-run
@test "Python module linter for all MAKESTER__PYTHONPATH override: dry" {
    MAKESTER__PYTHONPATH=something_else run make -f makefiles/makester.mk py-lint-all --dry-run
    assert_output --regexp "pylint something_else"
    [ "$status" -eq 0 ]
}

# bats test_tags=target,py-lint,dry-run
@test "Python module formatter LINT_PATH undefined: dry" {
    run make -f makefiles/makester.mk py-lint --dry-run
    assert_output --partial '### "LINT_PATH" undefined'
    [ "$status" -eq 2 ]
}
# bats test_tags=target,py-lint,dry-run
@test "Python module formatter LINT_PATH set: dry" {
    LINT_PATH=src/makester run make -f makefiles/makester.mk py-lint --dry-run
    assert_output '### Linting Python files under "src/makester"
pylint src/makester'
    [ "$status" -eq 0 ]
}
