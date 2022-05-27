variable "aws_iam_role_prefix" {
  description = "Prefix for name of IAM role that will be assumed by GitHub for OIDC"
  type        = string
  default     = "github-actions-oidc"
}

variable "aws_iam_role_separator" {
  description = "Character to use to separate words in name of IAM role"
  type        = string
  default     = "-"
}

variable "github_custom_claim" {
  description = "Custom OIDC claim for more specific access scope within a repository"
  type        = string
  default     = "*"
}

variable "github_repos" {
  description = "Set of GitHub repositories to configure, in owner/repo format"
  type        = set(string)
}
