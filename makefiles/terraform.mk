ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := terraform-help
endif

ifndef MAKESTER__PRIMED
$(info ### Add the following include statement to your Makefile)
$(info include makester/makefiles/makester.mk)
$(error ### missing include dependency)
endif

MAKESTER__TERRAFORM_EXE_NAME ?= terraform
MAKESTER__TERRAFORM_EXE_INSTALL ?= https://github.com/tfutils/tfenv
MAKESTER__TERRAFORM ?= $(call check-exe,$(MAKESTER__TERRAFORM_EXE_NAME),$(MAKESTER__TERRAFORM_EXE_INSTALL),optional)

MAKESTER__TERRAFORM_PATH ?= $(MAKESTER__PROJECT_DIR)/terraform

_terraform-cmd:
	$(if $(MAKESTER__TERRAFORM),,$(call _terraform-cmd-err))
	$(MAKESTER__TERRAFORM) -chdir=$(MAKESTER__TERRAFORM_PATH) $(_TERRAFORM_CMD)

define _terraform-cmd-err
	$(info ### MAKESTER__TERRAFORM: <undefined>)
	$(info ### MAKESTER__TERRAFORM_EXE_NAME set as "$(MAKESTER__TARRAFORM_EXE_NAME)")
	$(call check-exe,$(MAKESTER__TARRAFORM_EXE_NAME),$(MAKESTER__TARRAFORM_EXE_INSTALL))
endef

ifneq (,$(wildcard $(MAKESTER__TERRAFORM)))
  MAKESTER__TERRAFORM_VERSION ?= $(shell $(MAKESTER__TERRAFORM) version -json | jq .terraform_version | tr -d '"')
endif

ifdef MAKESTER__TERRAFORM_RESOURCE
  _TERRAFORM_RESOURCE ?= $(MAKESTER__TERRAFORM_RESOURCE)
endif

define _setup_provider_heredoc
cat <<EOF > $1/provider.tf
terraform {
  required_version = "~> $2"
}
EOF
endef

export _setup_provider = $(call _setup_provider_heredoc,$(MAKESTER__TERRAFORM_PATH),$(MAKESTER__TERRAFORM_VERSION))

# Flat directory project layout.
tf-project-create:
	$(info ### Creating a Terraform project directory structure under $(MAKESTER__TERRAFORM_PATH))
	@$(shell which mkdir) -pv $(MAKESTER__TERRAFORM_PATH)
	@$(shell which touch) $(MAKESTER__TERRAFORM_PATH)/data.tf
	@$(shell which touch) $(MAKESTER__TERRAFORM_PATH)/locals.tf
	@$(shell which touch) $(MAKESTER__TERRAFORM_PATH)/main.tf
	@$(shell which touch) $(MAKESTER__TERRAFORM_PATH)/provider.tf
	@$(shell which touch) $(MAKESTER__TERRAFORM_PATH)/terraform.tfvars
	@eval "$$_setup_provider"

# Command: state rm
#
tf-state-ls: _tf-state-ls-msg _tf-state-ls
_tf-state-ls: _TERRAFORM_CMD = state list $(_TERRAFORM_RESOURCE)
_tf-state-ls-msg:
	$(info ### listing all resources with the current Terraform state ...)

# Command: state rm
#
tf-pristine: _tf-pristine-msg _tf-pristine
_tf-pristine: _TERRAFORM_CMD = state rm $(_TERRAFORM_RESOURCE)
_tf-pristine-msg:
	$(info ### remove a binding to an existing remote object without first destroying it ...)
	$(call check-defined,MAKESTER__TERRAFORM_RESOURCE)

tf-init: _TERRAFORM_CMD = init
tf-validate: _TERRAFORM_CMD = validate
tf-plan: _TERRAFORM_CMD = plan
tf-apply: _TERRAFORM_CMD = apply
tf-destroy: _TERRAFORM_CMD = destroy

tf-fmt: _TERRAFORM_CMD = fmt -recursive
tf-fmt-check: _TERRAFORM_CMD = fmt -check -recursive
tf-fmt-diff: _TERRAFORM_CMD = fmt -diff -recursive

tf-console: _TERRAFORM_CMD = console

# Check the version of Terraform.
tf-version: _TERRAFORM_CMD = --version

# Terraform workspaces.
tf-ws-delete: _tf-ws-delete-msg _tf-ws-delete
_tf-ws-delete: _TERRAFORM_CMD = workspace delete $(MAKESTER__TERRAFORM_WS)
_tf-ws-delete-msg:
	$(info ### deleting workspace "$(MAKESTER__TERRAFORM_WS)" ...)
	$(call check-defined,MAKESTER__TERRAFORM_WS)

tf-ws-list: _tf-ws-list-msg _tf-ws-list
_tf-ws-list: _TERRAFORM_CMD = workspace list
_tf-ws-list-msg:
	$(info ### listing available workspaces ...)

tf-ws-new: _tf-ws-new-msg _tf-ws-new
_tf-ws-new: _TERRAFORM_CMD = workspace new $(MAKESTER__TERRAFORM_WS)
_tf-ws-new-msg:
	$(info ### creating workspace "$(MAKESTER__TERRAFORM_WS)" ...)
	$(call check-defined,MAKESTER__TERRAFORM_WS)

tf-ws-select: _tf-ws-select-msg _tf-ws-select
_tf-ws-select: _TERRAFORM_CMD = workspace select $(MAKESTER__TERRAFORM_WS)
_tf-ws-select-msg:
	$(info ### selecting workspace "$(MAKESTER__TERRAFORM_WS)" ...)
	$(call check-defined,MAKESTER__TERRAFORM_WS)

tf-apply \
tf-check \
tf-console \
tf-destroy \
tf-fmt \
tf-fmt-check \
tf-fmt-diff \
tf-init \
tf-plan \
_tf-pristine \
_tf-state-ls \
tf-validate \
tf-version \
_tf-ws-delete \
_tf-ws-list \
_tf-ws-new \
_tf-ws-select: _terraform-cmd

terraform-help:
	@echo "(makefiles/terraform.mk)\n\
  tf-apply             Terraform apply\n\
  tf-destroy           Terraform destroy\n\
  tf-fmt-apply         Apply Terraform formatting changes\n\
  tf-fmt-check         Check if Terraform files are formatted\n\
  tf-fmt-diff          Diff the Terraform formatting changes\n\
  tf-init              Terraform init\n\
  tf-plan              Terraform plan\n\
  tf-validate          Terraform validate\n\
  tf-version           Terraform version\n\
  tf-ws-dev            Terraform change to \"dev\" workspace\n\
  tf-ws-list           Terraform list workspaces\n\
  tf-ws-prod           Terraform change to \"prod\" workspace\n"

.PHONY: terraform-help
