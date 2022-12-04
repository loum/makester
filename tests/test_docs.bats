# Docs test runner.
#
#   tests/bats/bin/bats --file-filter docs tests
#
# bats file_tags=docs
setup_file() {
    export MAKESTER__PROJECT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/makester-XXXXXX")
}
setup() {
    load 'test_helper/common-setup'
    _common_setup
}
teardown_file() {
    MAKESTER__WORK_DIR=$MAKESTER__WORK_DIR make -f makefiles/makester.mk makester-work-dir-rm
}

# Docs include dependencies.
#
# Makester.
# bats test_tags=docs-dependencies
@test "Check if Makester is primed: false" {
    run make -f makefiles/docs.mk
    assert_output --partial '### Add the following include statement to your Makefile
include makester/makefiles/makester.mk'
    [ "$status" -eq 2 ]
}
# bats test_tags=docs-dependencies
@test "Check if Makester is primed: true" {
    run make -f makefiles/makester.mk -f makefiles/docs.mk docs-help
    assert_output --partial '(makefiles/docs.mk)'
    [ "$status" -eq 0 ]
}

# Docs variables.
#
# bats test_tags=variables,docs-variables,MAKESTER__DOCS_DIR
@test "MAKESTER__DOCS_DIR should be set when calling docs.mk" {
    run make -f makefiles/makester.mk -f makefiles/docs.mk print-MAKESTER__DOCS_DIR
    assert_output --regexp 'MAKESTER__DOCS_DIR=/.*/makester-[a-zA-Z0-9]{4,8}/docs'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,docs-variables,MAKESTER__DOCS_DIR
@test "MAKESTER__DOCS_DIR override" {
    MAKESTER__DOCS_DIR=dummy run make -f makefiles/makester.mk -f makefiles/docs.mk print-MAKESTER__DOCS_DIR
    assert_output --regexp 'MAKESTER__DOCS_DIR=dummy'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,docs-variables,MAKESTER__DOCS_IP
@test "MAKESTER__DOCS_IP should be set when calling docs.mk" {
    run make -f makefiles/makester.mk -f makefiles/docs.mk print-MAKESTER__DOCS_IP
    assert_output --regexp 'MAKESTER__DOCS_IP=[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,docs-variables,MAKESTER__DOCS_IP
@test "MAKESTER__DOCS_IP override" {
    MAKESTER__DOCS_IP=0.0.0.0\
 run make -f makefiles/makester.mk -f makefiles/docs.mk print-MAKESTER__DOCS_IP
    assert_output 'MAKESTER__DOCS_IP=0.0.0.0'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,docs-variables,MAKESTER__DOCS_BUILD_PATH
@test "MAKESTER__DOCS_BUILD_PATH should be set when calling docs.mk" {
    run make -f makefiles/makester.mk -f makefiles/docs.mk print-MAKESTER__DOCS_BUILD_PATH
    assert_output --regexp 'MAKESTER__DOCS_BUILD_PATH=/.*/makester-[a-zA-Z0-9]{4,8}/docs/site'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,docs-variables,MAKESTER__DOCS_BUILD_PATH
@test "MAKESTER__DOCS_BUILD_PATH override" {
    MAKESTER__DOCS_BUILD_PATH=dummy\
 run make -f makefiles/makester.mk -f makefiles/docs.mk print-MAKESTER__DOCS_BUILD_PATH
    assert_output 'MAKESTER__DOCS_BUILD_PATH=dummy'
    [ "$status" -eq 0 ]
}

# Targets.
#
# bats test_tags=targets,docs-targets,docs-bootstrap,dry-run
@test "Docs project bootstrap: dry" {
    run make -f makefiles/makester.mk -f makefiles/docs.mk docs-bootstrap --dry-run
    assert_output --regexp '### Bootstrapping project documentation at "/.*/makester-[a-zA-Z0-9]{4,8}/docs"
.*/3env/bin/mkdocs new /.*/makester-[a-zA-Z0-9]{4,8}/docs'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,docs-targets,docs-preview,dry-run
@test "Docs project live server: dry" {
    run make -f makefiles/makester.mk -f makefiles/docs.mk docs-preview --dry-run
    assert_output --regexp '### Starting the live preview server at "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:8000"'
    [ "$status" -eq 0 ]
}
# bats test_tags=targets,docs-targets,docs-preview,dry-run
@test "Docs project live server override: dry" {
    MAKESTER__DOCS_IP=0.0.0.0 MAKESTER__DOCS_PORT=18999\
 run make -f makefiles/makester.mk -f makefiles/docs.mk docs-preview --dry-run
    assert_output --regexp '### Starting the live preview server at "0.0.0.0:18999" .*
cd /.*/makester-[a-zA-Z0-9]{4,8}/docs;\\
 .*/3env/bin/mkdocs serve --dev-addr 0.0.0.0:18999 --watch /.*/makester-[a-zA-Z0-9]{4,8}/docs'
    [ "$status" -eq 0 ]
}

# bats test_tags=targets,docs-targets,docs-build,dry-run
@test "Docs static site builder: dry" {
    run make -f makefiles/makester.mk -f makefiles/docs.mk docs-build --dry-run
    assert_output --regexp '### Building static project documentation at "/.*/makester-[a-zA-Z0-9]{4,8}/docs/site"
cd /.*/makester-[a-zA-Z0-9]{4,8}/docs; .*/3env/bin/mkdocs build --site-dir /.*/makester-[a-zA-Z0-9]{4,8}/docs/site'
    [ "$status" -eq 0 ]
}
# bats test_tags=targets,docs-targets,docs-build,dry-run
@test "Docs static site builder override: dry" {
    MAKESTER__DOCS_BUILD_PATH=dummy run make -f makefiles/makester.mk -f makefiles/docs.mk docs-build --dry-run
    assert_output --regexp '### Building static project documentation at "dummy"
cd /.*/makester-[a-zA-Z0-9]{4,8}/docs;\ .*/3env/bin/mkdocs build --site-dir dummy'
    [ "$status" -eq 0 ]
}
