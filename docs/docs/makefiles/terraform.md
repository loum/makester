# Terraform

!!! tag "[Makester v0.2.5](https://github.com/loum/makester/releases/tag/0.2.5){target="_blank"}"

[Terraform](https://developer.hashicorp.com/terraform){target="_blank"} is an infrastructure as code
tool that lets you build, change, and version infrastructure safely and efficiently.

!!! warning
    **Caveat emptor**: The intro was ripped from the official Terraform page. Makester is by no way endorsing
    [Terraform](https://developer.hashicorp.com/terraform){target="_blank"} as a preferred IaC. There are probably
    better ways to handle infrastructure deployments. Consider this only as a basic Terraform primer. For example,
    to stand up a managed Kubernetes cluster where you can then leverage GitOps. The less DevOps in your project,
    the better ...

It is wise to take a pragmatic approach to DevOps as it is an evolving discipline. I have seen projects put too
much faith in the DevOps process which ultimately leads to rigid systems that are prone to failure and resistance
to change. In a fast-moving technological landscape aim to build flexible systems that evolve with emerging
trends, and are not to the detriment of the product. Furthermore, DevOps is not a panacea for bad system design ...

If you are embarking on your first DevOps project with Terraform, get ready for version skew,
incompatibilities, conflicts, provider decay, the list goes on. As you start working on
more Terraform projects you will notice that the only consistency when it comes to project
layouts is that they will all be different. That is where the major consultancy firms will burn
you with convoluted pre-baked deployments that they on-sell to unsuspecting clients who are blinded by the
quick-win fallacy of the OpEx revolution. As the consultancies are the only ones that can operate and manage
the ensuing mess, you're stuck with that turd until you come to your senses.

## Getting started

Ensure [Terraform](https://developer.hashicorp.com/terraform/install){target="_blank"} is available in
your path [(we recommend installing tfenv)](https://github.com/tfutils/tfenv){target="_blank"}.

If you are operating Makester in [minimal mode](../../getting-started#minimal-mode), then
append `terraform` to `MAKESTER__INCLUDES` to enable the Makester Terraform subsystem.

## Command reference

## Create a simple Terraform project directory layout

``` sh
make tf-project-create
```

Makester will produce the following directory layout:

``` sh
terraform
├── data.tf
├── locals.tf
├── main.tf
├── provider.tf
├── terraform.tfvars
```

`provider.tf` is pre-populated with the standard `terraform` block, ready to start adding your
providers. All other files within the `terraform` directory are simple stubs, only.

With new Terraform configuration files in place, you will need to
[initialise the working directory](#initialise-a-terraform-working-directory).

### Initialise a Terraform working directory
[Terraform command: init](https://developer.hashicorp.com/terraform/cli/commands/init){target="_blank"}

This is the first command that should be run after writing a new Terraform configuration and is
safe to re-run multiple times.


``` sh
make tf-init
```

### Validate Terraform configuration files
[Terraform command: init](https://developer.hashicorp.com/terraform/cli/commands/validate){target="_blank"}

Checks if configuration is syntactically valid and internally consistent. Validation does not access remote state. 

``` sh
make tf-validate
```

### Display current Terraform version
[Terraform command: init](https://developer.hashicorp.com/terraform/cli/commands/version){target="_blank"}

``` sh
make tf-version
```

### Preview the Terraform execution plan
[Terraform command: init](https://developer.hashicorp.com/terraform/cli/commands/plan){target="_blank"}

Report on state changes before applying.

``` sh
make tf-plan
```

### Execute the Terraform execution plan
[Terraform command: init](https://developer.hashicorp.com/terraform/cli/commands/apply){target="_blank"}

Applies the Terraform configuration in the working directory.

``` sh
make tf-apply
```

### Destroy all remote objects managed by Terraform configuration
[Terraform command: init](https://developer.hashicorp.com/terraform/cli/commands/destroy){target="_blank"}

``` sh
make tf-destroy
```

### Rewrite Terraform configuration with consistent formatting
[Terraform command: init](https://developer.hashicorp.com/terraform/cli/commands/fmt){target="_blank"}

Formatting is based on a subset of the
[Terraform language style conventions](https://developer.hashicorp.com/terraform/language/syntax/style){target="_blank"}.

``` sh
make tf-fmt
```

### Check Terraform configuration formatting
[Terraform command: init](https://developer.hashicorp.com/terraform/cli/commands/fmt/#check){target="_blank"}

Report on Terraform configuration files that are subject to formatting changes.

``` sh
make tf-fmt-check
```

### Display Terraform configuration formatting diffs
[Terraform command: init](https://developer.hashicorp.com/terraform/cli/commands/fmt/#diff){target="_blank"}

Display Terraform configuration file formatting differences.

``` sh
make tf-fmt-diff
```

### Launch interactive console
[Terraform command: init](https://developer.hashicorp.com/terraform/cli/commands/console){target="_blank"}

Console allows you to evaluate Terraform expressions and interact with any values that are
currently saved in the configuration state.

``` sh
make tf-console
```

### Inspecting infrastructure state
[Terraform command: state list](https://developer.hashicorp.com/terraform/cli/commands/state/list){target="_blank"}

List all resources in the state file:

``` sh
make tf-state-ls 
```

It is possible to filter resources by providing an address to the `MAKESTER__TERRAFORM_RESOURCE` variable:

``` sh
make tf-state-ls MAKESTER__TERRAFORM_RESOURCE=<OBJECT_ADDRESS>
```

### Workspaces: list all available workspaces
[Terraform command: state list](https://developer.hashicorp.com/terraform/cli/commands/workspace/list){target="_blank"}

``` sh
make tf-ws-list MAKESTER__TERRAFORM_WS=<WORKSPACE_NAME>
```

### Workspaces: create a new workspace
[Terraform command: state list](https://developer.hashicorp.com/terraform/cli/commands/workspace/new){target="_blank"}

Create a new Terraform workspace as per the value defined by [MAKESTER__TERRAFORM_WS](#makester__terraform_ws).

``` sh
make tf-ws-new MAKESTER__TERRAFORM_WS=<WORKSPACE_NAME>
```

### Workspaces: delete a workspace
[Terraform command: state list](https://developer.hashicorp.com/terraform/cli/commands/workspace/delete){target="_blank"}

Delete Terraform workspace defined by [MAKESTER__TERRAFORM_WS](#makester__terraform_ws).

``` sh
make tf-ws-delete MAKESTER__TERRAFORM_WS=<WORKSPACE_NAME>
```

### Workspaces: choose a workspace to use
[Terraform command: state list](https://developer.hashicorp.com/terraform/cli/commands/workspace/select){target="_blank"}

Select Terraform workspace defined by [MAKESTER__TERRAFORM_WS](#makester__terraform_ws).

``` sh
make tf-ws-select MAKESTER__TERRAFORM_WS=<WORKSPACE_NAME>
```

### Remove a local binding to an existing remote object without first destroying it
[Terraform command: state rm](https://developer.hashicorp.com/terraform/cli/commands/state/rm){target="_blank"}

Remove a binding to an existing remote object without first destroying it. This makes Terraform "forget"
the object while it continues to exist in the remote system.

``` sh
make tf-pristine MAKESTER__TERRAFORM_RESOURCE=<ADDRESS>
```

!!! note
    `ADDRESS` must be provided. Otherwise an error is generated.

## Variables

### `MAKESTER__TERRAFORM_PATH`
Switch to a different working directory before executing the given subcommand.
Defaults to `$(MAKESTER__PROJECT_DIR)/terraform`.

See [Switching working directory with `-chdir`](https://developer.hashicorp.com/terraform/cli/commands#switching-working-directory-with-chdir){target="_blank"}.

### `MAKESTER__TERRAFORM_WS`
Control Terraform workspace context. Default is `default`.

See [Workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces){target="_blank"}.


### `MAKESTER__TERRAFORM_RESOURCE`
Name of an address to the Terraform commands that supports resource filtering.

---
[top](#terraform)
