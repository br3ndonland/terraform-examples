# IAM policy examples

## GitHub Actions OIDC provisioning

[Credentials are required for the AWS Terraform provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication), so that Terraform can apply the configurations in this repo. If using Terraform Cloud, credentials need to be specified there. The [IAM best practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html) recommend granting least privilege, so it is preferable to configure Terraform Cloud with only the minimal permissions it needs. This example demonstrates how to set up AWS credentials using [Terraform Cloud variables](https://www.terraform.io/docs/cloud/workspaces/variables.html). Be sure to set `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as _environment_ variables, not _Terraform_ variables, otherwise `Warning: Value for undeclared variable` may be seen. See the [AWS docs on creating OIDC identity providers](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) for more info on the IAM permissions required.

[AWS CLI IAM commands](https://docs.aws.amazon.com/cli/latest/reference/iam/index.html) look like this:

```sh
aws iam create-group \
  --group-name terraform-cloud

aws iam create-user \
  --user-name github-actions-oidc

aws iam add-user-to-group \
  --group-name terraform-cloud \
  --user-name github-actions-oidc

aws iam put-user-policy \
  --user-name github-actions-oidc \
  --policy-name github-actions-oidc-provisioning \
  --policy-document file://github-actions-oidc-provisioning.json

aws iam create-access-key \
  --user-name github-actions-oidc
```

The above commands can be performed with Terraform as well. See:

- [`aws_iam_group`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group)
- [`aws_iam_user`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user)
- [`aws_iam_user_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy)

The access key credentials can then be set as Terraform Cloud workspace variables.

| Key                               | Category |
| --------------------------------- | -------- |
| AWS_ACCESS_KEY_ID `SENSITIVE`     | env      |
| AWS_SECRET_ACCESS_KEY `SENSITIVE` | env      |
