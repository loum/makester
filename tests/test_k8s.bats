# K8s test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags k8s tests
#
# bats file_tags=k8s
setup() {
  load 'test_helper/common-setup'
  _common_setup
}

# K8s include dependencies.
#
# Makester.
# bats test_tags=k8s-dependencies
@test "Check if Makester is primed: false" {
    run make -f makefiles/k8s.mk
    assert_output --partial '### Add the following include statement to your Makefile
include makester/makefiles/makester.mk'
    [ "$status" -eq 2 ]
}
# bats test_tags=k8s-dependencies
@test "Check if Makester is primed: true" {
    run make -f makefiles/makester.mk -f makefiles/k8s.mk k8s-help
    assert_output --partial '(makefiles/k8s.mk)'
    [ "$status" -eq 0 ]
}
