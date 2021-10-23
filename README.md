# Terraform examples

## Introduction

This repo contains example [Terraform](https://www.terraform.io/) configurations.

## Introduction to Infrastructure as Code with Terraform

From [HashiCorp Learn: Terraform - Get started (AWS)](https://learn.hashicorp.com/collections/terraform/aws-get-started)

> Terraform is the infrastructure as code tool from HashiCorp. It is a tool for building, changing, and managing infrastructure in a safe, repeatable way. Operators and Infrastructure teams can use Terraform to manage environments with a configuration language called the HashiCorp Configuration Language (HCL) for human-readable, automated deployments.
>
> ### Infrastructure as Code
>
> If you are new to infrastructure as code as a concept, it is the process of managing infrastructure in a file or files rather than manually configuring resources in a user interface. A resource in this instance is any piece of infrastructure in a given environment, such as a virtual machine, security group, network interface, etc.
>
> At a high level, Terraform allows operators to use HCL to author files containing definitions of their desired resources on almost any provider (AWS, GCP, GitHub, Docker, etc) and automates the creation of those resources at the time of apply.
>
> ### Workflows
>
> A simple workflow for deployment will follow closely to the steps below. We will go over each of these steps and concepts more in-depth throughout these tutorials, so don't panic if you don't understand the concepts immediately.
>
> 1. Scope - Confirm what resources need to be created for a given project.
> 2. Author - Create the configuration file in HCL based on the scoped parameters
> 3. Initialize - Run terraform init in the project directory with the configuration files. This will download the correct provider plug-ins for the project.
> 4. Plan & Apply - Run terraform plan to verify creation process and then terraform apply to create real resources as well as state file that compares future changes in your configuration files to what actually exists in your deployment environment.
>
> ### Advantages of Terraform
>
> While many of the current tools for infrastructure as code may work in your environment, Terraform aims to have a few advantages for operators and organizations of any size.
>
> 1. Platform Agnostic
> 2. State Management
> 3. Operator Confidence
>
> ### Platform Agnostic
>
> In a modern datacenter, you may have several different clouds and platforms to support your various applications. With Terraform, you can manage a heterogenous environment with the same workflow by creating a configuration file to fit the needs of your project or organization.
>
> ### State Management
>
> Terraform creates a state file when a project is first initialized. Terraform uses this local state to create plans and make changes to your infrastructure. Prior to any operation, Terraform does a refresh to update the state with the real infrastructure. This means that Terraform state is the source of truth by which configuration changes are measured. If a change is made or a resource is appended to a configuration, Terraform compares those changes with the state file to determine what changes result in a new resource or resource modifications.
>
> ### Operator Confidence
>
> The workflow built into Terraform aims to instill confidence in users by promoting easily repeatable operations and a planning phase to allow users to ensure the actions taken by Terraform will not cause disruption in their environment. Upon terraform apply, the user will be prompted to review the proposed changes and must affirm the changes or else Terraform will not apply the proposed plan.

## Definitions

As explained in the [Terraform core workflow guide](https://www.terraform.io/guides/core-workflow.html), the [Terraform CLI docs](https://www.terraform.io/docs/cli/run/index.html) and the [Terraform glossary](https://www.terraform.io/docs/glossary.html):

- A declarative Terraform file is called a **[configuration](https://www.terraform.io/docs/configuration/index.html)**.
- After configuration, a [`terraform plan`](https://www.terraform.io/docs/commands/plan.html) can optionally be created.
- Then, [`terraform apply`](https://www.terraform.io/docs/commands/apply.html) will create the resources declared in the configuration and plan.
