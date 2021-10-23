# HashiCorp Learn: Terraform - Get started

https://learn.hashicorp.com/collections/terraform/aws-get-started

Docker demo:

```sh
mkdir terraform-docker-demo && cd $_
touch main.tf
```

```hcl
terraform {
  required_providers {
    docker = {
      source = "terraform-providers/docker"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.latest
  name  = "tutorial"
  ports {
    internal = 80
    external = 8000
  }
}

```
