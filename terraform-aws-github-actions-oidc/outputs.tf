output "role_arn" {
  value       = aws_iam_role.github_actions_oidc.arn
  description = "ARN of AWS IAM role that has been assumed"
}

output "role_name" {
  value       = aws_iam_role.github_actions_oidc.name
  description = "Name of AWS IAM role that has been assumed"
}
