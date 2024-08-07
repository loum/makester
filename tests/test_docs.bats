# Docs test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags docs tests
#
# bats file_tags=docs
setup() {
    load 'test_helper/common-setup'
    _common_setup
}

# Docs include dependencies.
#
# Makester.
# bats test_tags=docs-dependencies
@test "Check if Makester is primed: false" {
    run make -f makefiles/docs.mk

    assert_output --partial '### Add the following include statement to your Makefile
include makester/makefiles/makester.mk'

    assert_failure
}
# bats test_tags=docs-dependencies
@test "Check if Makester is primed: true" {
    run make -f makefiles/makester.mk docs-help

    assert_output --partial '(makefiles/docs.mk)'

    assert_success
}

# Docs variables.
#
# bats test_tags=variables,docs-variables,MAKESTER__DOCS_DIR
@test "MAKESTER__DOCS_DIR should be set when calling docs.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__DOCS_DIR

    assert_output --regexp "MAKESTER__DOCS_DIR=$PWD/docs"

    assert_success
}
# bats test_tags=variables,docs-variables,MAKESTER__DOCS_DIR
@test "MAKESTER__DOCS_DIR override" {
    MAKESTER__DOCS_DIR=dummy run make -f makefiles/makester.mk print-MAKESTER__DOCS_DIR

    assert_output --regexp 'MAKESTER__DOCS_DIR=dummy'

    assert_success
}

# bats test_tags=variables,docs-variables,MAKESTER__DOCS_IP
@test "MAKESTER__DOCS_IP should be set when calling docs.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__DOCS_IP

    assert_output --regexp 'MAKESTER__DOCS_IP=[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'

    assert_success
}
# bats test_tags=variables,docs-variables,MAKESTER__DOCS_IP
@test "MAKESTER__DOCS_IP override" {
    MAKESTER__DOCS_IP=0.0.0.0\
 run make -f makefiles/makester.mk print-MAKESTER__DOCS_IP

    assert_output 'MAKESTER__DOCS_IP=0.0.0.0'

    assert_success
}

# bats test_tags=variables,docs-variables,MAKESTER__DOCS_BUILD_PATH
@test "MAKESTER__DOCS_BUILD_PATH should be set when calling docs.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__DOCS_BUILD_PATH

    assert_output --regexp "MAKESTER__DOCS_BUILD_PATH=$PWD/docs/site"

    assert_success
}
# bats test_tags=variables,docs-variables,MAKESTER__DOCS_BUILD_PATH
@test "MAKESTER__DOCS_BUILD_PATH override" {
    MAKESTER__DOCS_BUILD_PATH=dummy run make -f makefiles/makester.mk print-MAKESTER__DOCS_BUILD_PATH

    assert_output 'MAKESTER__DOCS_BUILD_PATH=dummy'

    assert_success
}

# Targets.
#
# bats test_tags=targets,docs-targets,docs-bootstrap,dry-run
@test "Docs project bootstrap: dry" {
    MAKESTER__DOCS=mkdocs run make -f makefiles/makester.mk docs-bootstrap --dry-run

    assert_output --regexp "### Bootstrapping project documentation at \"$PWD/docs\"
mkdocs new $PWD/docs"

    assert_success
}

# bats test_tags=targets,docs-targets,docs-preview,dry-run
@test "Docs project live server: dry" {
    MAKESTER__DOCS=mkdocs run make -f makefiles/makester.mk docs-preview --dry-run
    assert_output --regexp '### Starting the live preview server at "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:8000"'
    [ "$status" -eq 0 ]
}
# bats test_tags=targets,docs-targets,docs-preview,dry-run
@test "Docs project live server override: dry" {
    MAKESTER__DOCS=mkdocs MAKESTER__DOCS_IP=0.0.0.0 MAKESTER__DOCS_PORT=18999\
 run make -f makefiles/makester.mk docs-preview --dry-run

    assert_output "### Starting the live preview server at \"0.0.0.0:18999\" (Ctrl-C to stop)
cd $PWD/docs; mkdocs serve --dev-addr 0.0.0.0:18999 --watch $PWD/docs"

    assert_success
}

# bats test_tags=targets,docs-targets,docs-build,dry-run
@test "Docs static site builder: dry" {
    MAKESTER__DOCS=mkdocs run make -f makefiles/makester.mk docs-build --dry-run

    assert_output --regexp "### Building static project documentation at \"$PWD/docs/site\"
cd $PWD/docs; mkdocs build --site-dir $PWD/docs/site"

    assert_success
}
# bats test_tags=targets,docs-targets,docs-build,dry-run
@test "Docs static site builder override: dry" {
    MAKESTER__DOCS=mkdocs MAKESTER__DOCS_BUILD_PATH=dummy run make -f makefiles/makester.mk docs-build --dry-run

    assert_output --regexp "### Building static project documentation at \"dummy\"
cd $PWD/docs; mkdocs build --site-dir dummy"

    assert_success
}

# bats test_tags=targets,docs-targets,docs-gh-deploy,dry-run
@test "Docs GitHub deploy: dry" {
    MAKESTER__DOCS=mkdocs run make -f makefiles/makester.mk docs-gh-deploy --dry-run

    assert_output "### Deploying static project documentation to GitHub
cd $PWD/docs; mkdocs gh-deploy --site-dir $PWD/docs/site --force"

    assert_success
}
# bats test_tags=targets,docs-targets,docs-gh-deploy,dry-run
@test "Docs GitHub deploy override: dry" {
    MAKESTER__DOCS=mkdocs MAKESTER__DOCS_BUILD_PATH=dummy\
 run make -f makefiles/makester.mk docs-gh-deploy --dry-run

    assert_output "### Deploying static project documentation to GitHub
cd $PWD/docs; mkdocs gh-deploy --site-dir dummy --force"

    assert_success
}
