terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "<YOUR_TERRAFORM_CLOUD_ORG>"
    workspaces {
      prefix = "aws-github-actions-oidc-"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.55"
    }
  }
  required_version = "~> 1.0"
}
