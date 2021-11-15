variable "aws_iam_role_name" {
  description = "Name for IAM role that will be assumed by GitHub for OIDC"
  type        = string
  default     = "github-actions-oidc"
}

variable "github_custom_claim" {
  description = "Custom OIDC claim for more specific access scope within a repository"
  type        = string
  default     = "*"
}

variable "github_org" {
  description = "GitHub user or organization name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository from which the role can be assumed"
  type        = string
}
