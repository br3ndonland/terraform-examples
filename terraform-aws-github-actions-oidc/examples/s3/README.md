# GitHub Actions OIDC S3 example

## Description

This is an example of how to use the `github-actions-oidc` module to configure OIDC and attach identity-based policies to the [assumed IAM role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_terms-and-concepts.html).

Assumed roles can have two kinds of IAM policies attached: [resource-based and identity-based policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_identity-vs-resource.html).

- A _resource-based policy_ called a "role trust policy" defines how the role can be assumed. The role trust policy is already configured by the `github-actions-oidc` module.
- _Identity-based policies_ define what the credentials from the role can do once the role has been assumed, in terms of interactions with other resources on AWS. These need to be configured.

IAM identity-based policies can be attached to the assumed role by creating [`aws_iam_role_policy_attachment` resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment), as shown in the [example](./main.tf).

See the [HashiCorp Learn Terraform IAM policy tutorial](https://learn.hashicorp.com/tutorials/terraform/aws-iam-policy) and the [docs on the AWS provider `iam_policy_document` data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) for further info on authoring IAM policies for Terraform.

Note some duplicate variable declarations in the [example `variables.tf` file](./variables.tf). All input variables used in a Terraform configuration must be explicitly declared, even if they are already declared in a child module.

## Variables

If using the [Terraform Cloud remote backend](https://www.terraform.io/docs/cloud/workspaces/variables.html), the following variables should be set in the remote workspace.

| Key                               | Category  |
| --------------------------------- | --------- |
| AWS_ACCESS_KEY_ID `SENSITIVE`     | env       |
| AWS_SECRET_ACCESS_KEY `SENSITIVE` | env       |
| aws_provider_region               | terraform |
| aws_s3_bucket_name                | terraform |
| github_org                        | terraform |
| github_repo                       | terraform |
