# HashiCorp Learn: Terraform - Deploy Serverless Applications with AWS Lambda and API Gateway

https://learn.hashicorp.com/tutorials/terraform/lambda-api-gateway?in=terraform/aws

## Quickstart

```sh
❯ terraform init

❯ terraform apply

...

Apply complete! Resources: 0 added, 2 changed, 0 destroyed.

Outputs:

base_url = "https://<AWS_ACCOUNT_HASH>.execute-api.<AWS_REGION>.amazonaws.com/<API_GATEWAY_STAGE_NAME>"
function_name = "hashicorp-learn-terraform-lambda-api-gateway-python"
lambda_bucket_name = "hashicorp-learn-terraform-literate-halibut"
```

```sh
❯ aws lambda invoke --region=AWS_REGION --function-name=$(terraform output -raw function_name) response.json
```

```json
{
  "statusCode": 200,
  "headers": { "Content-Type": "application/json" },
  "body": "{'message': 'Hello, World!', 'details': 'Python Lambda function example'}"
}
```

```sh
❯ curl "$(terraform output -raw base_url)/hello?Name=Terraform"

{'message': 'Hello, Terraform!', 'details': 'Python Lambda function example'}
```

```sh
❯ terraform destroy
```

## Description

Code in this directory is adapted from [hashicorp/learn-terraform-lambda-api-gateway](https://github.com/hashicorp/learn-terraform-lambda-api-gateway), and updated for Python instead of JavaScript. The updates are similar to [gsweene2/serverless-rest-api](https://github.com/gsweene2/serverless-rest-api), with some modifications:

- Update to the [AWS Lambda Python 3.9 runtime](https://aws.amazon.com/blogs/compute/python-3-9-runtime-now-available-in-aws-lambda/), which requires hashicorp/aws `>= 3.55.0` to use AWS Lambda Python 3.9 runtime (see [hashicorp/terraform-provider-aws#20590](https://github.com/hashicorp/terraform-provider-aws/issues/20590))
- Configure the Python code as an explicit package: This setup is a more conventional approach to a [Python package](https://docs.python.org/3/tutorial/modules.html#packages). [Lambda confusingly refers to the .zip archives as "packages"](https://docs.aws.amazon.com/lambda/latest/dg/python-package.html), but Lambda "packages" are not necessarily Python packages.
- Add `__init__.py`: [Python packages](https://docs.python.org/3/tutorial/modules.html) should include `__init__.py` in the package directory. The [AWS Lambda Python 3.9 runtime](https://aws.amazon.com/blogs/compute/python-3-9-runtime-now-available-in-aws-lambda/) now properly initializes packages by reading `__init__.py` files.
- Add `_types.py`: based on [aws-lambda-context](https://pypi.org/project/aws-lambda-context/), but with a type for the `event` argument added, and updated to use [structural subtyping protocols](https://mypy.readthedocs.io/en/stable/protocols.html) instead of direct class inheritance.
- Move `terraform {}` block to _terraform.tf_
- Configure remote state in Terraform Cloud: Note that [this requires AWS credentials to be set as Terraform Cloud variables](https://support.hashicorp.com/hc/en-us/articles/4407141049491), because Terraform Cloud won't read local _~/.aws/credentials_ files. HashiCorp [recommends](https://www.terraform.io/docs/cloud/workspaces/variables.html#sensitive-values) using Terraform Cloud _environment_ variables instead of Terraform Cloud _Terraform_ variables for security.
- Add links to docs
  - [AWS Lambda docs: Developer Guide - AWS Lambda foundations - Concepts](https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-concepts.html)
  - [AWS Lambda docs: Developer Guide - Permissions - IAM Lambda execution role](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html)
  - [AWS Lambda docs: Developer Guide - Python - Lambda context object in Python](https://docs.aws.amazon.com/lambda/latest/dg/python-context.html)
  - [AWS Lambda docs: Developer Guide - Python - Lambda function handler in Python](https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html)
  - [AWS Lambda docs: Developer Guide - Python - Packaging Lambda functions](https://docs.aws.amazon.com/lambda/latest/dg/python-package.html)
  - [Terraform AWS Provider docs: Resource - `aws_apigatewayv2_api`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api)
  - [Terraform docs: Language - Functions](https://www.terraform.io/docs/language/functions/index.html)
