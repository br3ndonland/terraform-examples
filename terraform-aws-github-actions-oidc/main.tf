locals {
  github_repos       = { for repo in var.github_repos : replace(repo, "/", "-") => repo }
  oidc_client_ids    = ["sts.amazonaws.com"]
  oidc_issuer_domain = "token.actions.githubusercontent.com"
}

# Fetch TLS certificate thumbprint from OIDC provider

data "tls_certificate" "github" {
  url = "https://${local.oidc_issuer_domain}/.well-known/openid-configuration"
}

# Create a single GitHub Actions OIDC provider

resource "aws_iam_openid_connect_provider" "github" {
  client_id_list  = local.oidc_client_ids
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
  url             = "https://${local.oidc_issuer_domain}"
}

# Define resource-based role trust policy for each IAM role
# https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_identity-vs-resource.html

data "aws_iam_policy_document" "role_trust_policy" {
  for_each = local.github_repos
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
      values   = ["repo:${each.value}:${var.github_custom_claim}"]
    }
  }
}

# Create IAM roles for each repo and attach a role trust policy to each role
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp.html

resource "aws_iam_role" "github_actions_oidc" {
  for_each           = local.github_repos
  assume_role_policy = data.aws_iam_policy_document.role_trust_policy[each.key].json
  description        = "IAM assumed role for GitHub Actions in the ${each.value} repo"
  name = join(
    var.aws_iam_role_separator,
    flatten([var.aws_iam_role_prefix, split("/", each.value)])
  )
}
