# Makester test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags makester tests
#
# bats file_tags=makester
setup_file() {
    export MAKESTER__WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/makester-XXXXXX")
}
setup() {
    load 'test_helper/common-setup'
    _common_setup
}
teardown_file() {
    MAKESTER__PROJECT_DIR=$PWD make -f makefiles/makester.mk -f makefiles/docker.mk -f makefiles/versioning.mk gitversion-clear
    MAKESTER__WORK_DIR=$MAKESTER__WORK_DIR make -f makefiles/makester.mk makester-work-dir-rm
}

# Makester help.
#
# bats test_tags=help
@test "Makester help" {
    run make -f makefiles/makester.mk makester-help
    assert_output --partial '(makefiles/makester.mk)'
    [ "$status" -eq 0 ]
}

# Environment variable checker.
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

# Makester variables.
#
# MAKESTER__PRIMED
# bats test_tags=variables,makester-variables,MAKESTER__PRIMED
@test "MAKESTER__PRIMED should be set when calling makester.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PRIMED
    assert_output 'MAKESTER__PRIMED=true'
    [ "$status" -eq 0 ]
}

# MAKESTER__LOCAL_IP
# bats test_tags=variables,makester-variables,MAKESTER__LOCAL_IP
@test "Override MAKESTER__LOCAL_IP override" {
    MAKESTER__LOCAL_IP=127.0.0.1 run make -f makefiles/makester.mk print-MAKESTER__LOCAL_IP
    assert_output 'MAKESTER__LOCAL_IP=127.0.0.1'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,makester-variables,MAKESTER__RELEASE_VERSION
@test "MAKESTER__RELEASE_VERSION defaults to HASH" {
    run make -f makefiles/makester.mk print-MAKESTER__RELEASE_VERSION
    assert_output 'MAKESTER__RELEASE_VERSION=0.0.0'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__RELEASE_VERSION
@test "MAKESTER__RELEASE_VERSION with dynamic versioning" {
    MAKESTER__VERSION_FILE=$PWD/src/makester/VERSION\
 run make -f makefiles/makester.mk print-MAKESTER__RELEASE_VERSION
    assert_output --regexp '^MAKESTER__RELEASE_VERSION=[0-9]+\.[0-9]+\.[0-9]+[ab]{0,1}[0-9]{0,3}$'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__RELEASE_VERSION
@test "MAKESTER__RELEASE_VERSION override" {
    MAKESTER__RELEASE_VERSION=override run make -f makefiles/makester.mk print-MAKESTER__RELEASE_VERSION
    assert_output --regexp '^MAKESTER__RELEASE_VERSION=override$'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,makester-variables,MAKESTER__VERSION_FILE
@test "MAKESTER__VERSION_FILE default should be set when calling versioning.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__VERSION_FILE
    assert_output "MAKESTER__VERSION_FILE=$MAKESTER__WORK_DIR/VERSION"
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__VERSION_FILE
@test "MAKESTER__VERSION_FILE override" {
    MAKESTER__VERSION_FILE=my_package/VERSION run make -f makefiles/makester.mk print-MAKESTER__VERSION_FILE
    assert_output 'MAKESTER__VERSION_FILE=my_package/VERSION'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,makester-variables,MAKESTER__VERSION
@test "MAKESTER__VERSION default should be set when calling versioning.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__VERSION
    assert_output "MAKESTER__VERSION=0.0.0"
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__VERSION
@test "MAKESTER__VERSION override" {
    MAKESTER__VERSION=1.2.3 run make -f makefiles/makester.mk print-MAKESTER__VERSION
    assert_output 'MAKESTER__VERSION=1.2.3'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,makester-variables,MAKESTER__K8S_MANIFESTS
@test "MAKESTER__K8S_MANIFESTS should be set when calling makester.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__K8S_MANIFESTS
    assert_output --regexp 'MAKESTER__K8S_MANIFESTS=/.*/makester-[a-zA-Z0-9]{4,8}/k8s/manifests'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__K8S_MANIFESTS
@test "MAKESTER__K8S_MANIFESTS override" {
    MAKESTER__K8S_MANIFESTS=dummy run make -f makefiles/makester.mk print-MAKESTER__K8S_MANIFESTS
    assert_output --regexp 'MAKESTER__K8S_MANIFESTS=dummy'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,makester-variables,MAKESTER__PROJECT_DIR
@test "MAKESTER__PROJECT_DIR should be set when calling makester.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PROJECT_DIR
    assert_output --regexp "MAKESTER__PROJECT_DIR=$PWD"
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__PROJECT_DIR
@test "MAKESTER__PROJECT_DIR override" {
    MAKESTER__PROJECT_DIR=dummy run make -f makefiles/makester.mk print-MAKESTER__PROJECT_DIR
    assert_output --regexp 'MAKESTER__PROJECT_DIR=dummy'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,makester-variables,MAKESTER__PACKAGE_NAME
@test "MAKESTER__PACKAGE_NAME default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PACKAGE_NAME
    assert_output 'MAKESTER__PACKAGE_NAME=makefiles'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__PACKAGE_NAME
@test "MAKESTER__PACKAGE_NAME override" {
    MAKESTER__PACKAGE_NAME=makester\
 run make -f makefiles/makester.mk print-MAKESTER__PACKAGE_NAME
    assert_output 'MAKESTER__PACKAGE_NAME=makester'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,makester-variables,MAKESTER__MAKEFILES
@test "MAKESTER__MAKEFILES default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__MAKEFILES
    assert_output "MAKESTER__MAKEFILES=makefiles"
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__MAKEFILES
@test "MAKESTER__MAKEFILES alternate when MAKESTER__SUBMODULE_NAME directory does exist" {
    MAKESTER__SUBMODULE_NAME=makefiles run make -f makefiles/makester.mk print-MAKESTER__MAKEFILES
    assert_output "MAKESTER__MAKEFILES=makester/makefiles"
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,makester-variables,MAKESTER__PYTHON_PROJECT_ROOT
@test "MAKESTER__PYTHON_PROJECT_ROOT default should be set when calling py.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__PYTHON_PROJECT_ROOT
    assert_output --regexp 'MAKESTER__PYTHON_PROJECT_ROOT=/.*/src/makefiles'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__PYTHON_PROJECT_ROOT
@test "MAKESTER__PYTHON_PROJECT_ROOT override" {
    MAKESTER__PYTHON_PROJECT_ROOT=$PWD\
 run make -f makefiles/makester.mk print-MAKESTER__PYTHON_PROJECT_ROOT
    assert_output --regexp 'MAKESTER__PYTHON_PROJECT_ROOT=/.*/.*makester'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,makester-variables,MAKESTER__SERVICE_NAME
@test "MAKESTER__SERVICE_NAME default should be set when calling py.mk" {
    _LOCAL_REGISTRY_IS_ACTIVE="" run make -f makefiles/makester.mk print-MAKESTER__SERVICE_NAME
    assert_output 'MAKESTER__SERVICE_NAME=makefiles'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__SERVICE_NAME
@test "MAKESTER__SERVICE_NAME override" {
    _LOCAL_REGISTRY_IS_ACTIVE="" MAKESTER__SERVICE_NAME="whatever"\
 run make -f makefiles/makester.mk print-MAKESTER__SERVICE_NAME
    assert_output 'MAKESTER__SERVICE_NAME=whatever'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__SERVICE_NAME
@test "MAKESTER__SERVICE_NAME with MAKESTER__REPO_NAME value" {
    _LOCAL_REGISTRY_IS_ACTIVE="" MAKESTER__REPO_NAME=supa-repo\
 run make -f makefiles/makester.mk print-MAKESTER__SERVICE_NAME
    assert_output 'MAKESTER__SERVICE_NAME=supa-repo/makefiles'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__SERVICE_NAME
@test "MAKESTER__SERVICE_NAME override with MAKESTER__REPO_NAME value" {
    _LOCAL_REGISTRY_IS_ACTIVE="" MAKESTER__SERVICE_NAME="whatever" MAKESTER__REPO_NAME=supa-repo\
 run make -f makefiles/makester.mk print-MAKESTER__SERVICE_NAME
    assert_output 'MAKESTER__SERVICE_NAME=whatever'
    [ "$status" -eq 0 ]
}

# bats test_tags=variables,makester-variables,MAKESTER__STATIC_SERVICE_NAME
@test "MAKESTER__STATIC_SERVICE_NAME default should be set when calling py.mk" {
    _LOCAL_REGISTRY_IS_ACTIVE="" run make -f makefiles/makester.mk print-MAKESTER__STATIC_SERVICE_NAME
    assert_output 'MAKESTER__STATIC_SERVICE_NAME=makefiles'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__STATIC_SERVICE_NAME
@test "MAKESTER__STATIC_SERVICE_NAME with MAKESTER__SERVICE_NAME override" {
    _LOCAL_REGISTRY_IS_ACTIVE="" MAKESTER__SERVICE_NAME="whatever"\
 run make -f makefiles/makester.mk print-MAKESTER__STATIC_SERVICE_NAME
    assert_output 'MAKESTER__STATIC_SERVICE_NAME=whatever'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__STATIC_SERVICE_NAME
@test "MAKESTER__STATIC_SERVICE_NAME with MAKESTER__REPO_NAME value" {
    _LOCAL_REGISTRY_IS_ACTIVE="" MAKESTER__REPO_NAME=supa-repo\
 run make -f makefiles/makester.mk print-MAKESTER__STATIC_SERVICE_NAME
    assert_output 'MAKESTER__STATIC_SERVICE_NAME=supa-repo/makefiles'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__STATIC_SERVICE_NAME
@test "MAKESTER__STATIC_SERVICE_NAME override with MAKESTER__REPO_NAME value" {
    _LOCAL_REGISTRY_IS_ACTIVE="" MAKESTER__SERVICE_NAME="whatever" MAKESTER__REPO_NAME=supa-repo\
 run make -f makefiles/makester.mk print-MAKESTER__STATIC_SERVICE_NAME
    assert_output 'MAKESTER__STATIC_SERVICE_NAME=whatever'
    [ "$status" -eq 0 ]
}
# bats test_tags=variables,makester-variables,MAKESTER__STATIC_SERVICE_NAME
@test "MAKESTER__STATIC_SERVICE_NAME override but clobbered by MAKESTER__SERVICE_NAME" {
    _LOCAL_REGISTRY_IS_ACTIVE="" MAKESTER__STATIC_SERVICE_NAME="whatever"\
 run make -f makefiles/makester.mk print-MAKESTER__STATIC_SERVICE_NAME
    assert_output 'MAKESTER__STATIC_SERVICE_NAME=makefiles'
    [ "$status" -eq 0 ]
}

# Targets.
#
# bats test_tags=target,check-exe
@test "check-exe rule for \"GIT\" finds the executable" {
    run make -f makefiles/makester.mk print-GIT
    assert_output --regexp 'GIT=.*/git'
    [ "$status" -eq 0 ]
}

# bats test_tags=target,makester-gitignore,dry-run
@test "Project level .gitignore copy: dry" {
    MAKESTER__PROJECT_DIR=$PWD run make -f makefiles/makester.mk makester-gitignore --dry-run
    assert_output --regexp "/.*/cp /.*/makester/resources/project.gitignore $PWD/.gitignore"
    [ "$status" -eq 0 ]
}
# bats test_tags=target,makester-gitignore,dry-run
@test "Project level .gitignore copy override: dry" {
    MAKESTER__PROJECT_DIR=$PWD MAKESTER__RESOURCES_DIR=$PWD/resources\
 run make -f makefiles/makester.mk makester-gitignore --dry-run
    assert_output --regexp "/.*/cp /.*/resources/project.gitignore $PWD/.gitignore"
    [ "$status" -eq 0 ]
}

# bats test_tags=target,makester-mit-license,dry-run
@test "Project level MIT license copy: dry" {
    MAKESTER__PROJECT_DIR=$PWD run make -f makefiles/makester.mk makester-mit-license --dry-run
    assert_output --regexp "/.*/cp /.*/makester/resources/mit.md $PWD/LICENSE"
    [ "$status" -eq 0 ]
}
# bats test_tags=target,makester-mit-license,dry-run
@test "Project level MIT license copy override: dry" {
    MAKESTER__PROJECT_DIR=$PWD MAKESTER__RESOURCES_DIR=$PWD/resources\
 run make -f makefiles/makester.mk makester-mit-license --dry-run
    assert_output --regexp "/.*/cp /.*/resources/mit.md $PWD/LICENSE"
    [ "$status" -eq 0 ]
}
