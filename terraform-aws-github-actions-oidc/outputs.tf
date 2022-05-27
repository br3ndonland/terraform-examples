output "aws_iam_roles" {
  depends_on  = [aws_iam_role.github_actions_oidc]
  description = "ARNs and names of AWS IAM roles that have been provisioned"
  value = {
    for key, value in local.github_repos :
    key => {
      arn  = aws_iam_role.github_actions_oidc[key].arn
      name = aws_iam_role.github_actions_oidc[key].name
    }
  }
}
