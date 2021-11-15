variable "aws_provider_region" {
  description = "AWS region to use when configuring AWS Terraform provider"
  type        = string
  default     = "us-east-1"
}

variable "aws_s3_bucket_name" {
  type = string
}

variable "github_org" {
  description = "GitHub user or organization name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository from which the role can be assumed"
  type        = string
}
