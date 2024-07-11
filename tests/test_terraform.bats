# Terraform test runner.
#
# Can be executed manually with:
#   tests/bats/bin/bats --filter-tags terraform tests
#
# bats file_tags=terraform
setup() {
  load 'test_helper/common-setup'
  _common_setup
}

# Terraform include dependencies.
#
# Makester.
# bats test_tags=terraform-dependencies
@test "Check if Makester is primed: false" {
    run make -f makefiles/terraform.mk

    assert_output --partial '### Add the following include statement to your Makefile
include makester/makefiles/makester.mk'

    assert_failure
}
# bats test_tags=terraform-dependencies
@test "Check if Makester is primed: true" {
    run make -f makefiles/makester.mk terraform-help

    assert_output --partial '(makefiles/terraform.mk)'

    assert_success
}

# Terraform variables.
#
# bats test_tags=variables,terraform-variables,MAKESTER__TERRAFORM_VERSION
@test "MAKESTER__TERRAFORM_VERSION override" {
    MAKESTER__TERRAFORM_VERSION=1.6.1 run make -f makefiles/makester.mk print-MAKESTER__TERRAFORM_VERSION

    assert_output 'MAKESTER__TERRAFORM_VERSION=1.6.1'

    assert_success
}

# bats test_tags=variables,terraform-variables,MAKESTER__TERRAFORM_EXE_NAME
@test "MAKESTER__TERRAFORM_EXE_NAME default should be set when calling terraform.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__TERRAFORM_EXE_NAME

    assert_output 'MAKESTER__TERRAFORM_EXE_NAME=terraform'

    assert_success
}
# bats test_tags=variables,terraform-variables,MAKESTER__TERRAFORM_EXE_NAME
@test "MAKESTER__TERRAFORM_EXE_NAME override" {
    MAKESTER__TERRAFORM_EXE_NAME=/usr/local/bin/terraform\
 run make -f makefiles/makester.mk print-MAKESTER__TERRAFORM_EXE_NAME

    assert_output 'MAKESTER__TERRAFORM_EXE_NAME=/usr/local/bin/terraform'

    assert_success
}

# bats test_tags=variables,terraform-variables,MAKESTER__TERRAFORM_EXE_INSTALL
@test "MAKESTER__TERRAFORM_EXE_INSTALL default should be set when calling terraform.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__TERRAFORM_EXE_INSTALL

    assert_output 'MAKESTER__TERRAFORM_EXE_INSTALL=https://github.com/tfutils/tfenv'

    assert_success
}
# bats test_tags=variables,terraform-variables,MAKESTER__TERRAFORM_EXE_INSTALL
@test "MAKESTER__TERRAFORM_EXE_INSTALL override" {
    MAKESTER__TERRAFORM_EXE_INSTALL=http://localhost:8000\
 run make -f makefiles/makester.mk print-MAKESTER__TERRAFORM_EXE_INSTALL

    assert_output 'MAKESTER__TERRAFORM_EXE_INSTALL=http://localhost:8000'

    assert_success
}

# bats test_tags=variables,terraform-variables,MAKESTER__TERRAFORM_WS
@test "MAKESTER__TERRAFORM_WS override" {
    MAKESTER__TERRAFORM_WS=production\
 run make -f makefiles/makester.mk print-MAKESTER__TERRAFORM_WS

    assert_output 'MAKESTER__TERRAFORM_WS=production'

    assert_success
}

# bats test_tags=variables,terraform-variables,MAKESTER__TERRAFORM_PATH
@test "MAKESTER__TERRAFORM_PATH default should be set when calling terraform.mk" {
    run make -f makefiles/makester.mk print-MAKESTER__TERRAFORM_PATH

    assert_output "MAKESTER__TERRAFORM_PATH=$PWD/terraform"

    assert_success
}
# bats test_tags=variables,terraform-variables,MAKESTER__TERRAFORM_PATH
@test "MAKESTER__TERRAFORM_PATH override" {
    MAKESTER__TERRAFORM_PATH=dummy\
 run make -f makefiles/makester.mk print-MAKESTER__TERRAFORM_PATH

    assert_output 'MAKESTER__TERRAFORM_PATH=dummy'

    assert_success
}

# Targets.
#
# bats test_tags=targets,terraform-targets,tf-project-create,dry-run
@test "Terraform flat directory project create: dry" {
    MAKESTER__TERRAFORM=terraform run make -f makefiles/makester.mk tf-project-create --dry-run

    assert_output --regexp "### Creating a Terraform project directory structure under $PWD/terraform
/.*/mkdir -pv $PWD/terraform
/.*/touch $PWD/terraform/data.tf
/.*/touch $PWD/terraform/locals.tf
/.*/touch $PWD/terraform/main.tf
/.*/touch $PWD/terraform/provider.tf
/.*/touch $PWD/terraform/terraform.tfvars
eval \"\\$\_setup_provider\""

    assert_success
}

# bats test_tags=targets,terraform-targets,tf-state-ls,dry-run
@test "List existing Terraform resources: dry" {
    MAKESTER__TERRAFORM=terraform run make -f makefiles/makester.mk tf-state-ls --dry-run

    assert_output --regexp "### listing all resources with the current Terraform state ...
terraform -chdir=$PWD/terraform state list"

    assert_success
}
# bats test_tags=targets,terraform-targets,tf-state-ls,dry-run
@test "List existing Terraform resources MAKESTER__TERRAFORM_RESOURCE override: dry" {
    MAKESTER__TERRAFORM=terraform MAKESTER__TERRAFORM_RESOURCE=module.banana \
 run make -f makefiles/makester.mk tf-state-ls --dry-run

    assert_output --regexp "### listing all resources with the current Terraform state ...
terraform -chdir=$PWD/terraform state list module.banana"

    assert_success
}

# bats test_tags=targets,terraform-targets,tf-pristine,dry-run
@test "Remove Terraform resource state: dry" {
    MAKESTER__TERRAFORM=terraform MAKESTER__TERRAFORM_RESOURCE=module.banana \
 run make -f makefiles/makester.mk tf-pristine --dry-run

    assert_output --regexp "### remove a binding to an existing remote object without first destroying it ...
terraform -chdir=$PWD/terraform state rm module.banana"

    assert_success
}
# bats test_tags=targets,terraform-targets,tf-pristine,dry-run
@test "Remove Terraform resource state MAKESTER__TERRAFORM_RESOURCE undefined: dry" {
    MAKESTER__TERRAFORM=terraform run make -f makefiles/makester.mk tf-pristine --dry-run

    assert_output --regexp '### remove a binding to an existing remote object without first destroying it ...
### "MAKESTER__TERRAFORM_RESOURCE" undefined
###'

    assert_failure
}

# bats test_tags=targets,terraform-targets,tf-init,dry-run
@test "Initialise a Terraform working directory: dry" {
    MAKESTER__TERRAFORM=terraform run make -f makefiles/makester.mk tf-init --dry-run

    assert_output "terraform -chdir=$PWD/terraform init"

    assert_success
}

# bats test_tags=targets,terraform-targets,tf-validate,dry-run
@test "Validate Terraform configuration files: dry" {
    MAKESTER__TERRAFORM=terraform run make -f makefiles/makester.mk tf-validate --dry-run

    assert_output "terraform -chdir=$PWD/terraform validate"

    assert_success
}

# bats test_tags=targets,terraform-targets,tf-plan,dry-run
@test "Preview the Terraform execution plan: dry" {
    MAKESTER__TERRAFORM=terraform run make -f makefiles/makester.mk tf-plan --dry-run

    assert_output "terraform -chdir=$PWD/terraform plan"

    assert_success
}

# bats test_tags=targets,terraform-targets,tf-apply,dry-run
@test "Execute the Terraform execution plan: dry" {
    MAKESTER__TERRAFORM=terraform run make -f makefiles/makester.mk tf-apply --dry-run

    assert_output "terraform -chdir=$PWD/terraform apply"

    assert_success
}

# bats test_tags=targets,terraform-targets,tf-destroy,dry-run
@test "Destroy all remote objects managed by Terraform configuration: dry" {
    MAKESTER__TERRAFORM=terraform run make -f makefiles/makester.mk tf-destroy --dry-run

    assert_output "terraform -chdir=$PWD/terraform destroy"

    assert_success
}

# bats test_tags=targets,terraform-targets,tf-fmt,dry-run
@test "Rewrite Terraform configuration with consistent formatting: dry" {
    MAKESTER__TERRAFORM=terraform run make -f makefiles/makester.mk tf-fmt --dry-run

    assert_output "terraform -chdir=$PWD/terraform fmt -recursive"

    assert_success
}

# bats test_tags=targets,terraform-targets,tf-fmt-check,dry-run
@test "Check Terraform configuration formatting: dry" {
    MAKESTER__TERRAFORM=terraform run make -f makefiles/makester.mk tf-fmt-check --dry-run

    assert_output "terraform -chdir=$PWD/terraform fmt -check -recursive"

    assert_success
}

# bats test_tags=targets,terraform-targets,tf-fmt-diff,dry-run
@test "Display Terraform configuration formatting diffs: dry" {
    MAKESTER__TERRAFORM=terraform run make -f makefiles/makester.mk tf-fmt-diff --dry-run

    assert_output "terraform -chdir=$PWD/terraform fmt -diff -recursive"

    assert_success
}

# bats test_tags=targets,terraform-targets,tf-console,dry-run
@test "Launch interactive console: dry" {
    MAKESTER__TERRAFORM=terraform run make -f makefiles/makester.mk tf-console --dry-run

    assert_output "terraform -chdir=$PWD/terraform console"

    assert_success
}

# bats test_tags=targets,terraform-targets,tf-version,dry-run
@test "Display current Terraform version: dry" {
    MAKESTER__TERRAFORM=terraform run make -f makefiles/makester.mk tf-version --dry-run

    assert_output "terraform -chdir=$PWD/terraform --version"

    assert_success
}

# bats test_tags=targets,terraform-targets,tf-ws-delete,dry-run
@test "Workspaces - delete a workspace: dry" {
    MAKESTER__TERRAFORM=terraform run make -f makefiles/makester.mk tf-ws-delete MAKESTER__TERRAFORM_WS=dummy --dry-run

    assert_output "### deleting workspace \"dummy\" ...
terraform -chdir=$PWD/terraform workspace delete dummy"

    assert_success
}

# bats test_tags=targets,terraform-targets,tf-ws-new,dry-run
@test "Workspaces - create a new workspace: dry" {
    MAKESTER__TERRAFORM=terraform run make -f makefiles/makester.mk tf-ws-new MAKESTER__TERRAFORM_WS=dummy --dry-run

    assert_output "### creating workspace \"dummy\" ...
terraform -chdir=$PWD/terraform workspace new dummy"

    assert_success
}

# bats test_tags=targets,terraform-targets,tf-ws-list,dry-run
@test "Workspaces - list all available workspaces: dry" {
    MAKESTER__TERRAFORM=terraform run make -f makefiles/makester.mk tf-ws-list --dry-run

    assert_output "### listing available workspaces ...
terraform -chdir=$PWD/terraform workspace list"

    assert_success
}

# bats test_tags=targets,terraform-targets,tf-ws-select,dry-run
@test "Workspaces - select a workspace: dry" {
    MAKESTER__TERRAFORM=terraform run make -f makefiles/makester.mk tf-ws-select MAKESTER__TERRAFORM_WS=dummy --dry-run

    assert_output "### selecting workspace \"dummy\" ...
terraform -chdir=$PWD/terraform workspace select dummy"

    assert_success
}
