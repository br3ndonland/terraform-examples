locals {
  oidc_client_ids         = ["sts.amazonaws.com"]
  oidc_issuer_domain      = "token.actions.githubusercontent.com"
  oidc_subject_conditions = ["repo:${var.github_org}/${var.github_repo}:${var.github_custom_claim}"]
}

# Create OIDC provider
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider
resource "aws_iam_openid_connect_provider" "github" {
  client_id_list = local.oidc_client_ids
  thumbprint_list = [
    "a031c46782e6e6c662c2c87c76da9aa62ccabd8e",
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
  url = "https://${local.oidc_issuer_domain}"
}

# Define resource-based role trust policy for IAM role
# https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_identity-vs-resource.html
data "aws_iam_policy_document" "role_trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity", "sts:TagSession"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_domain}:aud"
      values   = local.oidc_client_ids
    }
    condition {
      test     = "StringLike"
      variable = "${local.oidc_issuer_domain}:sub"
      values   = local.oidc_subject_conditions
    }
  }
}

# Create role for OIDC provider and attach resource-based role trust policy
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp.html
resource "aws_iam_role" "github_actions_oidc" {
  name               = var.aws_iam_role_name
  description        = "IAM role with role trust policy defining how the role can be assumed"
  assume_role_policy = data.aws_iam_policy_document.role_trust_policy.json
}
