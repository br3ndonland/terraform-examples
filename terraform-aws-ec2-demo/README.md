# HashiCorp Learn: Terraform - Get started (AWS)

https://learn.hashicorp.com/collections/terraform/aws-get-started

## Lessons

### Build Infrastructure

> Authenticate to AWS, and create an EC2 instance under the AWS free tier. You will write and validate Terraform configuration, initialize a configuration directory, and plan and apply a configuration to create infrastructure.

[Configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) with `aws configure`, then create an HCL file _main.tf_.

```sh
mkdir terraform-aws-ec2-demo && cd $_
touch main.tf
```

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.55.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"
}

```

```sh
terraform init
terrraform fmt
terraform validate
terraform apply
terraform show
terraform state list
```

### Change Infrastructure

> Modify EC2-instance configuration to use a different Ubuntu version. Plan and apply the changes to re-provision a new instance that reflects the new configuration. Learn how Terraform handles infrastructure change management.

Update the AMI from `ami-830c94e3` to `ami-08d70e59c07c61a3a`, run `terraform apply` again, then verify with `terraform show`.

### Destroy Infrastructure

> Completely destroy the AWS infrastructure that Terraform manages in a configuration with a single command. Evaluate the plan and confirm the destruction.

Destroy with `terraform destroy`.

### Define Input Variables

> Declare your AWS region as a variable. Reference the variable in Terraform configuration. Define variables using command line flags, environment variables, .tfvars files or default values.
>
> You now have enough Terraform knowledge to create useful configurations, but we're still hard-coding access keys, AMIs, etc. To become truly shareable and version controlled, we need to parameterize the configurations. This page introduces input variables as a way to do this.

Add a file _variables.tf_, or add variables directly to _main.tf_.

```hcl
variable "region" {
  default = "us-west-2"
}

variable "ami" {
  default = "ami-08d70e59c07c61a3a"
}

```

_main.tf_

```hcl
resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = "t2.micro"
}

```

Maps can also be set up.

```hcl
variable "region" {
  default = "us-west-2"
}

variable "amis" {
  type = map(string)
  default = {
    "us-east-1" = "ami-b374d5a5"
    "us-west-2" = "ami-fc0b939c"
  }
}

```

_main.tf_

```hcl
resource "aws_instance" "example" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
}

```

### Query Data with Output Variables

> Declare output variables to display the public IP address of an EC2 instance. Display all outputs and query specific outputs. Define what data stored in Terraform state is relevant to the operator or end user.

```hcl
resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.example.id
}

output "ip" {
  value = aws_eip.ip.public_ip
}

```

After running `terraform apply`, view output with `terraform output ip`.

### Store Remote State

> Configure Terraform to store state in Terraform Cloud remote backend. Add a remote state block directly to configuration or set an environment variable to load remote state configuration when Terraform initializes.
>
> Now you have built, changed, and destroyed infrastructure from your local machine. This is great for testing and development, but in production environments you should keep your state secure and encrypted, where your teammates can access it to collaborate on infrastructure. The best way to do this is by running Terraform in a remote environment with shared access to state.
>
> Terraform [remote backends](https://www.terraform.io/docs/backends/index.html) allow Terraform to use a shared storage space for state data. The [Terraform Cloud](https://www.terraform.io/cloud) remote backend also allows teams to easily version, audit, and collaborate on infrastructure changes. Terraform Cloud also securely stores variables, including API tokens and access keys. It provides a safe, stable environment for long-running Terraform processes.
>
> In this tutorial you will migrate your state to Terraform Cloud.

Add a backend to the _main.tf_ file:

```hcl
terraform {
  backend "remote" {
    organization = "br3ndonland"
    workspaces {
      name = "HashiCorp-Learn"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.55.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_instance" "example" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.example.id
}

```

Generate an API token and log in with `terraform login`, initialize the backend with `terraform init`, and then run `terraform apply`. It may complain about lack of AWS credentials, and you may need to delete the local state file _terraform.tfstate_. To move the state back to local state, delete the `backend` block, and run `terraform apply` again. Finally, run `terraform destroy` to remove the resources.
