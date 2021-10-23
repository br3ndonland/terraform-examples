# freeCodeCamp Terraform course

https://www.freecodecamp.org/news/how-to-use-terraform-to-automate-your-aws-cloud-infrastructure-tutorial/

## Setup

- I skipped over this because I had already done [HashiCorp Learn: Terraform - Get Started with AWS](https://learn.hashicorp.com/collections/terraform/aws-get-started). See [notes](terraform-hashicorp-learn.md).
- Finishes around 0.39.00

## Terraform overview

- 0.21.00 Getting started
- 0.39.00 First deployment

## Modifying resources

- 0.46.00 Updating deployment: The instructor adds AWS resource tags

## Deleting resources

- 0.50.30

## Referencing resources

0.54.45

- Create a VPC (note that the docs shown have moved to the [Terraform Registry docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)).
- Add a CIDR block ("[Classless Inter-Domain Routing](https://tools.ietf.org/html/rfc4632)", a method of IP address assignment).
- Reference the VPC in the Terraform file

## Terraform files

1.04.50

- The order of your Terraform file doesn't matter.
- Don't manually edit _.tfstate_ files.

## Practice project

1.09.45: The instructor does a nice job of breaking the process down into actionable steps.

1. Create VPC
2. Create internet gateway
3. Create custom route table
4. Create subnet
5. Associate subnet with route table
6. Create security group to allow a port
7. Create network interface with an IP in the subnet created in step 4
8. Assign an elastic IP to the network interface created in step 7: The internet gateway must be created before the EIP (elastic IP) can be assigned. Terraform should be able to understand this on its own, based on the [docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip).
9. Create server resource and enable web server: Make sure AZs (availability zones) match up. The instructor gives a helpful explanation of `EOF`, which can be used to create an inline Bash shell script block.

## Terraform commands

1.50.30

## Terraform output

## Target resources

## Terraform variables

2.03.50

- See the [Terraform docs on variables](https://www.terraform.io/docs/configuration/variables.html).
- Note the typing capabilities.
- If a variable is declared, but a value is not assigned, the Terraform CLI will prompt for a value.
- Store variables in _.tfvars_ files.
