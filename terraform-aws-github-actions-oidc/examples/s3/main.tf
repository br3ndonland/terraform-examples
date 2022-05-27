locals {
  github_repos = {
    for repo in var.github_repos :
    replace(repo, "/", "-") => {
      owner = split("/", repo)[0]
      repo  = split("/", repo)[1]
    }
  }
}

# Configure provider
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  region = var.aws_provider_region
}

# Call module
# https://www.terraform.io/docs/language/modules/syntax.html
# https://www.terraform.io/docs/cloud/registry/using.html
module "github_actions_oidc" {
  source       = "app.terraform.io/<YOUR_TERRAFORM_CLOUD_ORG>/github-actions-oidc/aws"
  github_repos = var.github_repos
}

# Define identity-based policies for IAM role (what the role can do after it has been assumed)
# https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_identity-vs-resource.html
data "aws_iam_policy_document" "s3_bucket" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.aws_s3_bucket_name}"]
  }
  statement {
    actions   = ["s3:DeleteObject", "s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${var.aws_s3_bucket_name}/*"]
  }
}

resource "aws_iam_policy" "s3_bucket" {
  name        = "github-actions-s3-${var.aws_s3_bucket_name}"
  description = "Allows access to a single S3 bucket with the given name"
  policy      = data.aws_iam_policy_document.s3_bucket.json
}

# Attach identity-based policies to IAM role
resource "aws_iam_role_policy_attachment" "s3_bucket_attachment" {
  for_each   = local.github_repos
  role       = module.github_actions_oidc.aws_iam_roles[each.key].name
  policy_arn = aws_iam_policy.s3_bucket.arn
}
