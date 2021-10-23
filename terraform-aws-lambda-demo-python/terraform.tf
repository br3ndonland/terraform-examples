terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "br3ndonland-training"
    workspaces {
      name = "hashicorp-learn-terraform-lambda-api-gateway-python"
    }
  }
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.55.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }
  required_version = "~> 1.0"
}
