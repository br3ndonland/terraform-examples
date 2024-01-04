# GitHub Actions OpenID Connect

**This example is also available in the GitHub repo [br3ndonland/terraform-aws-github-actions-oidc](https://github.com/br3ndonland/terraform-aws-github-actions-oidc) and in the Terraform registry as [br3ndonland/github-actions-oidc/aws](https://registry.terraform.io/modules/br3ndonland/github-actions-oidc/aws/latest).**

## Description

GitHub has [introduced](https://github.blog/changelog/2021-10-27-github-actions-secure-cloud-deployments-with-openid-connect/) OpenID Connect ("OIDC") for GitHub Actions (see [roadmap](https://github.com/github/roadmap/issues/249) and [docs](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments)). OIDC allows workflows to authenticate with AWS by assuming [IAM roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_terms-and-concepts.html) that grant temporary security credentials, instead of by using static AWS access keys stored in GitHub Secrets. See the AWS IAM docs on [creating OIDC providers](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) and [creating roles for OIDC providers](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp.html), and the [GitHub OIDC docs for AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services) for further info related to AWS.

The [aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials) repo recommends OIDC, but only provides a CloudFormation snippet. The implementation in this repo is the Terraform equivalent. The [AWS Terraform provider](https://registry.terraform.io/providers/hashicorp/aws/latest) includes an [`iam_openid_connect_provider`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) resource for OIDC.

## Usage

### Publish a module

This configuration is not directly published to a registry. Here are the steps needed to publish it.

- **Create a repo with the correct naming syntax for publishing Terraform modules**.
  - Repos containing Terraform modules should be named `terraform-<PROVIDER>-<MODULE>`, where `<MODULE>` can contain extra hyphens. This nomenclature is required to [publish to a module registry](https://www.terraform.io/docs/registry/modules/publish.html).
  - This configuration uses the [AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest), so the repo name might be `<YOUR_GITHUB_ORG>/terraform-aws-github-actions-oidc`.
- **Commit the Terraform module to the repo**.
  - See the [Terraform docs on module structure](https://www.terraform.io/docs/language/modules/develop/structure.html) for an explanation of the directory structure.
- **[Connect GitHub and Terraform Cloud](https://www.terraform.io/docs/cloud/vcs/index.html)**.
  - The [GitHub App](https://www.terraform.io/docs/cloud/vcs/github-app.html) is the easiest way to do this for github.com.
  - [Custom OAuth apps](https://www.terraform.io/docs/cloud/vcs/github.html) can also be used.
- **[Publish to a module registry](https://www.terraform.io/docs/registry/modules/publish.html)** to make the Terraform configuration reusable.
  - Public modules can be published to the [Terraform Public Module Registry](https://www.terraform.io/docs/cloud/registry/publish.html).
  - For organizations using Terraform Cloud, modules can be published to the [Private Module Registry](https://www.terraform.io/docs/cloud/registry/index.html) for internal use by the organization.
  - Modules use [semantic versioning](https://semver.org/). Push a Git tag to release a new version.

Now that the module is published, it can be imported and used in downstream configurations.

Run `terraform login` to [use modules from the Terraform Cloud Private Module Registry](https://www.terraform.io/docs/cloud/registry/using.html).

See [hectcastro/terraform-aws-github-actions-oidc](https://github.com/hectcastro/terraform-aws-github-actions-oidc), published to the Terraform Registry as [github-actions-oidc](https://registry.terraform.io/modules/hectcastro/github-actions-oidc/aws/latest), for a similar example.

### Prepare a downstream project to use the module

#### Configure state backend

Configure your [backend](https://www.terraform.io/docs/language/settings/backends/index.html) for Terraform state. An [example configuration](examples/s3/terraform.tf) for the [Terraform Cloud remote backend](https://www.terraform.io/docs/language/settings/backends/remote.html) is provided. Note that [credentials are required for the AWS Terraform provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication), so if using Terraform Cloud, credentials need to be specified there. See the [example](examples/iam/README.md) for how to set up these credentials.

#### Set variables

Set [Terraform input variables](https://www.terraform.io/docs/language/values/variables.html), either with a _.tfvars_ file, by passing them in directly with `-var`, or with [Terraform Cloud workspace variables](https://www.terraform.io/docs/cloud/workspaces/variables.html).

```hcl
# terraform.tfvars
github_custom_claim = "ref:refs/heads/main"          # optional
github_repos        = ["owner/repo0", "owner/repo1"] # REQUIRED
```

Variable definitions files named `terraform.tfvars` or `*.auto.tfvars` will be loaded automatically. If using a variable definitions file with a different name, use `-var-file=filename.tfvars` when running `terraform apply`.

#### Declare Terraform configuration

Next, declare Terraform configurations specific to the repos and policies you want to configure. See the _examples/_ directory for example configurations.

The module can be [used](https://www.terraform.io/docs/cloud/registry/using.html) by adding a `module` block, as shown in the [example](examples/s3/main.tf).

### Run Terraform

Then, [initialize and apply](https://www.terraform.io/guides/core-workflow.html) the Terraform configuration, specifying your [remote state backend config](https://www.terraform.io/docs/language/settings/backends/remote.html). If re-using the Terraform configuration for multiple repos, consider creating a [workspace](https://www.terraform.io/docs/language/state/workspaces.html) for each with `terraform workspace new <WORKSPACE_NAME>`.

```sh
terraform init
terraform apply
```
