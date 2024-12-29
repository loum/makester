# Python test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags py tests
#
# bats file_tags=py
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
    rmdir "$MAKESTER__PROJECT_DIR"
}

# Python include dependencies.
#
# Makester.
# bats test_tags=py-dependencies
@test "Check if Makester is primed: false" {
    run make -f makefiles/py.mk

    assert_output --partial '### Add the following include statement to your Makefile
include makester/makefiles/makester.mk'

    assert_failure
}
# bats test_tags=py-dependencies
@test "Check if Makester is primed: true" {
    run make -f makefiles/makester.mk py-help

    assert_output --partial '(makefiles/py.mk)'

    assert_success
}

# Python variables.
#
# bats test_tags=variables,py-variables,PYTHONPATH
@test "PYTHONPATH default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-PYTHONPATH

    assert_output "PYTHONPATH=$MAKESTER__PROJECT_DIR/src"

    assert_success
}
# bats test_tags=variables,py-variables,PYTHONPATH
@test "PYTHONPATH override" {
    PYTHONPATH=. run make -f makefiles/makester.mk print-PYTHONPATH

    assert_output --regexp 'PYTHONPATH=.'

    assert_success
}
#

# bats test_tags=variables,py-variables,MAKESTER__PYTHONPATH
@test "MAKESTER__PYTHONPATH default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PYTHONPATH

    assert_output "MAKESTER__PYTHONPATH=$MAKESTER__PROJECT_DIR/src"

    assert_success
}
# bats test_tags=variables,py-variables,MAKESTER__PYTHONPATH
@test "MAKESTER__PYTHONPATH override" {
    MAKESTER__PYTHONPATH=something_else run make -f makefiles/makester.mk print-MAKESTER__PYTHONPATH

    assert_output "MAKESTER__PYTHONPATH=something_else"

    assert_success
}

# MAKESTER__SYSTEM_PYTHON3
# bats test_tags=variables,py-variables,MAKESTER__SYSTEM_PYTHON3
@test "MAKESTER__SYSTEM_PYTHON3 default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__SYSTEM_PYTHON3

    assert_output --regexp 'MAKESTER__SYSTEM_PYTHON3=.*/python3'
    # We don't want the virtual environment Python here.
    refute_output --regexp 'MAKESTER__SYSTEM_PYTHON3=.*/3env'

    assert_success
}
# bats test_tags=variables,py-variables,MAKESTER__SYSTEM_PYTHON3
@test "MAKESTER__SYSTEM_PYTHON3 override" {
    MAKESTER__SYSTEM_PYTHON3=/usr/local/bin/banana\
 run make -f makefiles/makester.mk print-MAKESTER__SYSTEM_PYTHON3

    assert_output --regexp "makefiles/py.mk:[0-9]{1,5}:\
 \*\*\* ### No Python executable found: Check your MAKESTER__SYSTEM_PYTHON3=/usr/local/bin/banana setting.  Stop."

    assert_failure
}

# bats test_tags=variables,py-variables,MAKESTER__PY3_VERSION
@test "MAKESTER__PY3_VERSION default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PY3_VERSION

    assert_output --regexp 'MAKESTER__PY3_VERSION=Python 3\.[0-9]{1,2}\.[0-9]{1,2}'

    assert_success
}
# bats test_tags=variables,py-variables,MAKESTER__PY3_VERSION
@test "MAKESTER__PY3_VERSION override" {
    MAKESTER__PY3_VERSION="Python 3.9.13"\
 run make -f makefiles/makester.mk print-MAKESTER__PY3_VERSION

    assert_output 'MAKESTER__PY3_VERSION=Python 3.9.13'

    assert_success
}

# bats test_tags=variables,py-variables-private,_PY3_VERSION_FULL
@test "_PY3_VERSION_FULL default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-_PY3_VERSION_FULL

    assert_output --regexp '_PY3_VERSION_FULL=3 [0-9]{1,2} [0-9]{1,2}'

    assert_success
}
# bats test_tags=variables,py-variables-private,_PY3_VERSION_FULL
@test "_PY3_VERSION_FULL override" {
    MAKESTER__PY3_VERSION="Python 3.9.13"\
 run make -f makefiles/makester.mk print-_PY3_VERSION_FULL

    assert_output '_PY3_VERSION_FULL=3 9 13'

    assert_success
}

# bats test_tags=variables,py-variables,MAKESTER__WHEEL
@test "MAKESTER__WHEEL default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__WHEEL

    assert_output 'MAKESTER__WHEEL=~/wheelhouse'

    assert_success
}
# bats test_tags=variables,py-variables,MAKESTER__WHEEL
@test "MAKESTER__WHEEL override" {
    MAKESTER__WHEEL=~/.wheelhouse\
 run make -f makefiles/makester.mk print-MAKESTER__WHEEL

    assert_output --regexp 'MAKESTER__WHEEL=.*/\.wheelhouse'

    assert_success
}

# bats test_tags=variables,py-variables,MAKESTER__PIP_INSTALL
@test "MAKESTER__PIP_INSTALL default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PIP_INSTALL

    assert_output 'MAKESTER__PIP_INSTALL=-e .'

    assert_success
}
# bats test_tags=variables,py-variables,MAKESTER__PIP_INSTALL
@test "MAKESTER__PIP_INSTALL override" {
    MAKESTER__PIP_INSTALL=makester\
 run make -f makefiles/makester.mk print-MAKESTER__PIP_INSTALL

    assert_output --regexp 'MAKESTER__PIP_INSTALL=makester'

    assert_success
}

# bats test_tags=variables,py-variables,MAKESTER__PYLINT_RCFILE
@test "MAKESTER__PYLINT_RCFILE default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PYLINT_RCFILE

    assert_output --regexp 'MAKESTER__PYLINT_RCFILE=.*/pylintrc'

    assert_success
}
# bats test_tags=variables,py-variables,MAKESTER__PYLINT_RCFILE
@test "MAKESTER__PYLINT_RCFILE override" {
    MAKESTER__PYLINT_RCFILE=pylintrc\
 run make -f makefiles/makester.mk print-MAKESTER__PYLINT_RCFILE

    assert_output 'MAKESTER__PYLINT_RCFILE=pylintrc'

    assert_success
}

# bats test_tags=variables,py-variables,MAKESTER__PIP_INSTALL_EXTRAS
@test "MAKESTER__PIP_INSTALL_EXTRAS default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PIP_INSTALL_EXTRAS

    assert_output 'MAKESTER__PIP_INSTALL_EXTRAS=dev'

    assert_success
}
# bats test_tags=variables,py-variables,MAKESTER__PIP_INSTALL_EXTRAS
@test "MAKESTER__PIP_INSTALL_EXTRAS override" {
    MAKESTER__PIP_INSTALL_EXTRAS=test\
 run make -f makefiles/makester.mk print-MAKESTER__PIP_INSTALL_EXTRAS

    assert_output 'MAKESTER__PIP_INSTALL_EXTRAS=test'

    assert_success
}

# Targets.
#
# bats test_tags=target,py-vars
@test "Python system variables" {
    run make -f makefiles/makester.mk py-vars
    refute_output --regexp '### System python3: .*/3env/.*/python3'

    assert_success
}

# bats test_tags=target,py-install,dry-run
@test "Python package install: dry" {
    run make -f makefiles/makester.mk py-install --dry-run

    assert_output --regexp '### Installing project dependencies into .*/venv ...
.*/venv/bin/pip install --find-links=~/wheelhouse -e .'

    assert_success
}
# bats test_tags=target,py-install,dry-run
@test "Python package install MAKESTER__WHEEL override: dry" {
    MAKESTER__WHEEL=.wheelhouse\
 run make -f makefiles/makester.mk py-install --dry-run

    assert_output --regexp '### Installing project dependencies into .*/venv ...
.*/venv/bin/pip install --find-links=.wheelhouse -e \.'

    assert_success
}

# bats test_tags=target,py-install-extras,dry-run
@test "Python package extras install: dry" {
    run make -f makefiles/makester.mk py-install-extras --dry-run

    assert_output --regexp '### Installing project dependencies into .*/venv ...
.*/venv/bin/pip install --find-links=~/wheelhouse -e \.\[dev\]'

    assert_success
}
# bats test_tags=target,py-install-extras,dry-run
@test "Python package extras install MAKESTER__PIP_INSTALL_EXTRAS override: dry" {
    MAKESTER__PIP_INSTALL_EXTRAS="test" run make -f makefiles/makester.mk py-install-extras --dry-run

    assert_output --regexp '### Installing project dependencies into .*/venv ...
.*/venv/bin/pip install --find-links=~/wheelhouse -e \.\[test\]'

    assert_success
}

# bats test_tags=target,py-pylintrc,dry-run
@test "Python pylint configuration generator: dry" {
    run make -f makefiles/makester.mk py-pylintrc --dry-run

    assert_output --regexp 'pylint --generate-rcfile > /.*/pylintrc'

    assert_success
}
# bats test_tags=target,py-pylintrc,dry-run
@test "Python pylint configuration generator MAKESTER__PYLINT_RCFILE override: dry" {
    MAKESTER__PYLINT_RCFILE=pylintrc run make -f makefiles/makester.mk py-pylintrc --dry-run

    assert_output --regexp 'pylint --generate-rcfile > pylintrc'

    assert_success
}

# bats test_tags=target,py-deps,dry-run
@test "Python project package dependency dump" {
    run make -f makefiles/makester.mk py-deps --dry-run

    assert_output '### Displaying "makefiles" package dependencies ...
pipdeptree'

    assert_success
}

# bats test_tags=target,py-distribution,dry-run
@test "Python package builder: dry" {
    run make -f makefiles/makester.mk py-distribution --dry-run

    assert_output --regexp "/.*/python -m build"

    assert_success
}
# bats test_tags=target,py-distribution,dry-run
@test "Python package builder with MAKESTER__PYTHON override: dry" {
    MAKESTER__PYTHON=something_else run make -f makefiles/makester.mk py-distribution --dry-run

    assert_output --regexp "something_else -m build"

    assert_success
}

# bats test_tags=target,py-fmt-src,dry-run
@test "Python src modules formatter: dry" {
    run make -f makefiles/makester.mk py-fmt-src --dry-run

    assert_output "### Formatting Python files under \"$MAKESTER__PROJECT_DIR/src\"
black $MAKESTER__PROJECT_DIR/src"

    assert_success
}
# bats test_tags=target,py-fmt-src,dry-run
@test "Python src modules formatter with MAKESTER__PYTHONPATH override: dry" {
    MAKESTER__PYTHONPATH=something_else run make -f makefiles/makester.mk py-fmt-src --dry-run

    assert_output "### Formatting Python files under \"something_else\"
black something_else"

    assert_success
}

# bats test_tags=target,py-fmt-tests,dry-run
@test "Python tests modules formatter: dry" {
    run make -f makefiles/makester.mk py-fmt-tests --dry-run

    assert_output "### Formatting Python files under \"$MAKESTER__PROJECT_DIR/tests\"
black $MAKESTER__PROJECT_DIR/tests"

    assert_success
}
# bats test_tags=target,py-fmt-tests,dry-run
@test "Python tests modules formatter with MAKESTER__TESTS_PYTHONPATH override: dry" {
    MAKESTER__TESTS_PYTHONPATH=something_else run make -f makefiles/makester.mk py-fmt-tests --dry-run

    assert_output "### Formatting Python files under \"something_else\"
black something_else"

    assert_success
}

# bats test_tags=target,py-fmt-all,dry-run
@test "Python module formatter for all modules: dry" {
    run make -f makefiles/makester.mk py-fmt-all --dry-run

    assert_output "### Formatting Python files under \"$MAKESTER__PROJECT_DIR/src\"
black $MAKESTER__PROJECT_DIR/src
### Formatting Python files under \"$MAKESTER__PROJECT_DIR/tests\"
black $MAKESTER__PROJECT_DIR/tests"

    assert_success
}
# bats test_tags=target,py-fmt-all,dry-run
@test "Python module formatter for all MAKESTER__PYTHONPATH override: dry" {
    MAKESTER__PYTHONPATH=something_else run make -f makefiles/makester.mk py-fmt-all --dry-run

    assert_output "### Formatting Python files under \"something_else\"
black something_else
### Formatting Python files under \"$MAKESTER__PROJECT_DIR/tests\"
black $MAKESTER__PROJECT_DIR/tests"

    assert_success
}
# bats test_tags=target,py-fmt-all,dry-run
@test "Python module formatter for all MAKESTER__TESTS_PYTHONPATH override: dry" {
    MAKESTER__TESTS_PYTHONPATH=something_else run make -f makefiles/makester.mk py-fmt-all --dry-run

    assert_output "### Formatting Python files under \"$MAKESTER__PROJECT_DIR/src\"
black $MAKESTER__PROJECT_DIR/src
### Formatting Python files under \"something_else\"
black something_else"

    assert_success
}

# bats test_tags=target,py-fmt,dry-run
@test "Python module formatter FMT_PATH undefined: dry" {
    run make -f makefiles/makester.mk py-fmt --dry-run

    assert_output --partial '### "FMT_PATH" undefined'

    assert_failure
}
# bats test_tags=target,py-fmt,dry-run
@test "Python module formatter FMT_PATH set: dry" {
    FMT_PATH=src/makester run make -f makefiles/makester.mk py-fmt --dry-run

    assert_output '### Formatting Python files under "src/makester"
black src/makester'

    assert_success
}

# bats test_tags=target,py-lint-src,dry-run
@test "Python src modules linter: dry" {
    run make -f makefiles/makester.mk py-lint-src --dry-run

    assert_output "### Linting Python files under \"$MAKESTER__PROJECT_DIR/src\"
pylint $MAKESTER__PROJECT_DIR/src"

    assert_success
}
# bats test_tags=target,py-lint-src,dry-run
@test "Python src modules linter with MAKESTER__PYTHONPATH override: dry" {
    MAKESTER__PYTHONPATH=something_else run make -f makefiles/makester.mk py-lint-src --dry-run

    assert_output "### Linting Python files under \"something_else\"
pylint something_else"

    assert_success
}

# bats test_tags=target,py-lint-tests,dry-run
@test "Python tests modules linter: dry" {
    run make -f makefiles/makester.mk py-lint-tests --dry-run

    assert_output "### Linting Python files under \"$MAKESTER__PROJECT_DIR/tests\"
pylint $MAKESTER__PROJECT_DIR/tests"

    assert_success
}
# bats test_tags=target,py-lint-tests,dry-run
@test "Python tests modules linter with MAKESTER__TESTS_PYTHONPATH override: dry" {
    MAKESTER__TESTS_PYTHONPATH=something_else run make -f makefiles/makester.mk py-lint-tests --dry-run

    assert_output "### Linting Python files under \"something_else\"
pylint something_else"

    assert_success
}

# bats test_tags=target,py-lint-all,dry-run
@test "Python module linter for all under MAKESTER__PROJECTPATH: dry" {
    run make -f makefiles/makester.mk py-lint-all --dry-run

    assert_output "### Linting Python files under \"$MAKESTER__PROJECT_DIR/src\"
pylint $MAKESTER__PROJECT_DIR/src
### Linting Python files under \"$MAKESTER__PROJECT_DIR/tests\"
pylint $MAKESTER__PROJECT_DIR/tests"

    assert_success
}
# bats test_tags=target,py-lint-all,dry-run
@test "Python module linter for all MAKESTER__PYTHONPATH override: dry" {
    MAKESTER__PYTHONPATH=something_else run make -f makefiles/makester.mk py-lint-all --dry-run

    assert_output "### Linting Python files under \"something_else\"
pylint something_else
### Linting Python files under \"$MAKESTER__PROJECT_DIR/tests\"
pylint $MAKESTER__PROJECT_DIR/tests"

    assert_success
}
# bats test_tags=target,py-lint-all,dry-run
@test "Python module linter for all MAKESTER__TESTS_PYTHONPATH override: dry" {
    MAKESTER__TESTS_PYTHONPATH=something_else run make -f makefiles/makester.mk py-lint-all --dry-run

    assert_output "### Linting Python files under \"$MAKESTER__PROJECT_DIR/src\"
pylint $MAKESTER__PROJECT_DIR/src
### Linting Python files under \"something_else\"
pylint something_else"

    assert_success
}

# bats test_tags=target,py-lint,dry-run
@test "Python module linter LINT_PATH undefined: dry" {
    run make -f makefiles/makester.mk py-lint --dry-run

    assert_output --partial '### "LINT_PATH" undefined'

    assert_failure
}
# bats test_tags=target,py-lint,dry-run
@test "Python module linter LINT_PATH set: dry" {
    LINT_PATH=src/makester run make -f makefiles/makester.mk py-lint --dry-run

    assert_output '### Linting Python files under "src/makester"
pylint src/makester'

    assert_success
}

# bats test_tags=target,py-type-src,dry-run
@test "Python src modules type annotation: dry" {
    run make -f makefiles/makester.mk py-type-src --dry-run

    assert_output "### Type annotating Python files under \"$MAKESTER__PROJECT_DIR/src\"
mypy --disallow-untyped-defs $MAKESTER__PROJECT_DIR/src"

    assert_success
}
# bats test_tags=target,py-type-src,dry-run
@test "Python src modules type annotation MAKESTER__MYPY_OPTIONS override: dry" {
    MAKESTER__MYPY_OPTIONS=--check-untyped-defs run make -f makefiles/makester.mk py-type-src --dry-run

    assert_output "### Type annotating Python files under \"$MAKESTER__PROJECT_DIR/src\"
mypy --check-untyped-defs $MAKESTER__PROJECT_DIR/src"

    assert_success
}
# bats test_tags=target,py-type-src,dry-run
@test "Python src modules type annotation with MAKESTER__PYTHONPATH override: dry" {
    MAKESTER__PYTHONPATH=something_else run make -f makefiles/makester.mk py-type-src --dry-run

    assert_output "### Type annotating Python files under \"something_else\"
mypy --disallow-untyped-defs something_else"

    assert_success
}

# bats test_tags=target,py-type-tests,dry-run
@test "Python tests modules type annotation: dry" {
    run make -f makefiles/makester.mk py-type-tests --dry-run

    assert_output "### Type annotating Python files under \"$MAKESTER__PROJECT_DIR/tests\"
mypy --disallow-untyped-defs $MAKESTER__PROJECT_DIR/tests"

    assert_success
}
# bats test_tags=target,py-type-tests,dry-run
@test "Python tests modules type annotation MAKESTER__MYPY_OPTIONS override: dry" {
    MAKESTER__MYPY_OPTIONS=--check-untyped-defs run make -f makefiles/makester.mk py-type-tests --dry-run

    assert_output "### Type annotating Python files under \"$MAKESTER__PROJECT_DIR/tests\"
mypy --check-untyped-defs $MAKESTER__PROJECT_DIR/tests"

    assert_success
}
# bats test_tags=target,py-type-tests,dry-run
@test "Python tests modules type annotation with MAKESTER__TESTS_PYTHONPATH override: dry" {
    MAKESTER__TESTS_PYTHONPATH=something_else run make -f makefiles/makester.mk py-type-tests --dry-run

    assert_output "### Type annotating Python files under \"something_else\"
mypy --disallow-untyped-defs something_else"

    assert_success
}

# bats test_tags=target,py-type-all,dry-run
@test "Python module type annotation for all under MAKESTER__PROJECTPATH: dry" {
    run make -f makefiles/makester.mk py-type-all --dry-run

    assert_output "### Type annotating Python files under \"$MAKESTER__PROJECT_DIR/src\"
mypy --disallow-untyped-defs $MAKESTER__PROJECT_DIR/src
### Type annotating Python files under \"$MAKESTER__PROJECT_DIR/tests\"
mypy --disallow-untyped-defs $MAKESTER__PROJECT_DIR/tests"

    assert_success
}
# bats test_tags=target,py-type-all,dry-run
@test "Python module type annotation for all under MAKESTER__PROJECTPATH MAKESTER__MYPY_OPTIONS override: dry" {
    MAKESTER__MYPY_OPTIONS=--check-untyped-defs run make -f makefiles/makester.mk py-type-all --dry-run

    assert_output "### Type annotating Python files under \"$MAKESTER__PROJECT_DIR/src\"
mypy --check-untyped-defs $MAKESTER__PROJECT_DIR/src
### Type annotating Python files under \"$MAKESTER__PROJECT_DIR/tests\"
mypy --check-untyped-defs $MAKESTER__PROJECT_DIR/tests"

    assert_success
}
# bats test_tags=target,py-type-all,dry-run
@test "Python module type annotation for all MAKESTER__PYTHONPATH override: dry" {
    MAKESTER__PYTHONPATH=something_else run make -f makefiles/makester.mk py-type-all --dry-run

    assert_output "### Type annotating Python files under \"something_else\"
mypy --disallow-untyped-defs something_else
### Type annotating Python files under \"$MAKESTER__PROJECT_DIR/tests\"
mypy --disallow-untyped-defs $MAKESTER__PROJECT_DIR/tests"

    assert_success
}
# bats test_tags=target,py-type-all,dry-run
@test "Python module type annotation for all MAKESTER__TESTS_PYTHONPATH override: dry" {
    MAKESTER__TESTS_PYTHONPATH=something_else run make -f makefiles/makester.mk py-type-all --dry-run

    assert_output "### Type annotating Python files under \"$MAKESTER__PROJECT_DIR/src\"
mypy --disallow-untyped-defs $MAKESTER__PROJECT_DIR/src
### Type annotating Python files under \"something_else\"
mypy --disallow-untyped-defs something_else"

    assert_success
}

# bats test_tags=target,py-check,dry-run
@test "Python module all-in-one code validator: dry" {
    run make -f makefiles/makester.mk py-check --dry-run

    assert_output "### Formatting Python files under \"$MAKESTER__PROJECT_DIR/src\"
black $MAKESTER__PROJECT_DIR/src
### Formatting Python files under \"$MAKESTER__PROJECT_DIR/tests\"
black $MAKESTER__PROJECT_DIR/tests
### Linting Python files under \"$MAKESTER__PROJECT_DIR/src\"
pylint $MAKESTER__PROJECT_DIR/src
### Linting Python files under \"$MAKESTER__PROJECT_DIR/tests\"
pylint $MAKESTER__PROJECT_DIR/tests
### Type annotating Python files under \"$MAKESTER__PROJECT_DIR/src\"
mypy --disallow-untyped-defs $MAKESTER__PROJECT_DIR/src
### Type annotating Python files under \"$MAKESTER__PROJECT_DIR/tests\"
mypy --disallow-untyped-defs $MAKESTER__PROJECT_DIR/tests"

    assert_success
}

# bats test_tags=target,py-type,dry-run
@test "Python module type annotation formatter TYPE_PATH undefined: dry" {
    run make -f makefiles/makester.mk py-type --dry-run

    assert_output --partial '### "TYPE_PATH" undefined'

    assert_failure
}
# bats test_tags=target,py-type,dry-run
@test "Python module type annotation TYPE_PATH set: dry" {
    TYPE_PATH=src/makester run make -f makefiles/makester.mk py-type --dry-run

    assert_output '### Type annotating Python files under "src/makester"
mypy --disallow-untyped-defs src/makester'

    assert_success
}
