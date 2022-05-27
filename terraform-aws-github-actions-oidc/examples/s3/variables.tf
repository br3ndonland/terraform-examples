variable "aws_provider_region" {
  description = "AWS region to use when configuring AWS Terraform provider"
  type        = string
  default     = "us-east-1"
}

variable "aws_s3_bucket_name" {
  type = string
}

variable "github_repos" {
  description = "Set of GitHub repositories to configure, in owner/repo format"
  type        = set(string)
}
