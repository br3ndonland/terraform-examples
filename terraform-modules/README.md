# Terraform modules

From the [HashiCorp Learn Terraform modules collection](https://learn.hashicorp.com/collections/terraform/modules).

## Overview

> As you manage your infrastructure with Terraform, you will create increasingly complex configurations. There is no intrinsic limit to the complexity of a single Terraform configuration file or directory, so it is possible to continue writing and updating your configuration files in a single directory. However, if you do, you may encounter one or more problems:
>
> - Understanding and navigating the configuration files will become increasingly difficult.
> - Updating the configuration will become more risky, as an update to one section may cause unintended consequences to other parts of your configuration.
> - There will be an increasing amount of duplication of similar blocks of configuration, for instance when configuring separate dev/staging/production environments, which will cause an increasing burden when updating those parts of your configuration.
> - You may wish to share parts of your configuration between projects and teams, and will quickly find that cutting and pasting blocks of configuration between projects is error prone and hard to maintain.
>
> In this tutorial, you will learn how modules can address these problems, the structure of a Terraform module, and best practices when using and creating modules.
>
> Then, over the course of these tutorials, you will use and create Terraform modules to simplify your current workflow.
>
> ### What are modules for?
>
> Here are some of the ways that modules help solve the problems listed above:
>
> - **Organize configuration** - Modules make it easier to navigate, understand, and update your configuration by keeping related parts of your configuration together. Even moderately complex infrastructure can require hundreds or thousands of lines of configuration to implement. By using modules, you can organize your configuration into logical components.
> - **Encapsulate configuration** - Another benefit of using modules is to encapsulate configuration into distinct logical components. Encapsulation can help prevent unintended consequences, such as a change to one part of your configuration accidentally causing changes to other infrastructure, and reduce the chances of simple errors like using the same name for two different resources.
> - **Re-use configuration** - Writing all of your configuration from scratch can be time consuming and error prone. Using modules can save time and reduce costly errors by re-using configuration written either by yourself, other members of your team, or other Terraform practitioners who have published modules for you to use. You can also share modules that you have written with your team or the general public, giving them the benefit of your hard work.
> - **Provide consistency and ensure best practices** - Modules also help to provide consistency in your configurations. Not only does consistency make complex configurations easier to understand, it also helps to ensure that best practices are applied across all of your configuration.
>   - For instance, cloud providers give many options for configuring object storage services, such as Amazon S3 or Google Cloud Storage buckets. There have been many high-profile security incidents involving incorrectly secured object storage, and given the number of complex configuration options involved, it's easy to accidentally misconfigure these services.
>   - Using modules can help reduce these errors. For example, you might create a module to describe how all of your organization's public website buckets will be configured, and another module for private buckets used for logging applications. Also, if a configuration for a type of resource needs to be updated, using modules allows you to make that update in a single place and have it be applied to all cases where you use that module.
>
> ### What is a Terraform module?
>
> A Terraform module is a set of Terraform configuration files in a single directory. Even a simple configuration consisting of a single directory with one or more .tf files is a module. When you run Terraform commands directly from such a directory, it is considered the root module. So in this sense, every Terraform configuration is part of a module. You may have a simple set of Terraform configuration files such as:
>
> ```text
> .
> ├── LICENSE
> ├── README.md
> ├── main.tf
> ├── variables.tf
> ├── outputs.tf
> ```
>
> In this case, when you run terraform commands from within the minimal-module directory, the contents of that directory are considered the root module.
>
> ### Module best practices
>
> In many ways, Terraform modules are similar to the concepts of libraries, packages, or modules found in most programming languages, and provide many of the same benefits. Just like almost any non-trivial computer program, real-world Terraform configurations should almost always use modules to provide the benefits mentioned above.
>
> We recommend that every Terraform practitioner use modules by following these best practices:
>
> - **Name your provider `terraform-<PROVIDER>-<NAME>`**. You must follow this convention in order to [publish to the Terraform Cloud or Terraform Enterprise module registries](https://www.terraform.io/docs/cloud/registry/publish.html).
> - **Start writing your configuration with modules in mind**. Even for modestly complex Terraform configurations managed by a single person, you'll find the benefits of using modules outweigh the time it takes to use them properly.
> - **Use local modules to organize and encapsulate your code**. Even if you aren't using or publishing remote modules, organizing your configuration in terms of modules from the beginning will significantly reduce the burden of maintaining and updating your configuration as your infrastructure grows in complexity.
> - **Use the public Terraform Registry to find useful modules**. This way you can more quickly and confidently implement your configuration by relying on the work of others to implement common infrastructure scenarios.
> - **Publish and share modules with your team**. Most infrastructure is managed by a team of people, and modules are important way that teams can work together to create and maintain infrastructure. As mentioned earlier, you can publish modules either publicly or privately. We will see how to do this in a future tutorial in this series.

## Understand how modules work

> When using a new module for the first time, you must run either `terraform init` or `terraform get` to install the module. When either of these commands are run, Terraform will install any new modules in the `.terraform/modules` directory within your configuration's working directory. For local modules, Terraform will create a symlink to the module's directory. Because of this, any changes to local modules will be effective immediately, without having to re-run `terraform get`.
>
> After following this tutorial, your `.terraform/modules` directory will look something like this:
>
> ```text
> .terraform/modules/
> ├── ec2_instances
> ├── modules.json
> └── vpc
> ```

## Build and use a local module

> ### Module structure
>
> While using existing Terraform modules correctly is an important skill, every Terraform practitioner will also benefit from learning how to create modules. In fact, we recommend that every Terraform configuration be created with the assumption that it may be used as a module, because doing so will help you design your configurations to be flexible, reusable, and composable.
>
> Terraform treats any local directory referenced in the source argument of a `module` block as a module. A typical file structure for a new module is:
>
> ```text
> .
> ├── LICENSE
> ├── README.md
> ├── main.tf
> ├── variables.tf
> ├── outputs.tf
> ```
>
> None of these files are required, or have any special meaning to Terraform when it uses your module. You can create a module with a single .tf file, or use any other file structure you like.
>
> Each of these files serves a purpose:
>
> - `LICENSE` will contain the license under which your module will be distributed. When you share your module, the LICENSE file will let people using it know the terms under which it has been made available. Terraform itself does not use this file.
> - `README`.md will contain documentation describing how to use your module, in markdown format. Terraform does not use this file, but services like the Terraform Registry and GitHub will display the contents of this file to people who visit your module's Terraform Registry or GitHub page.
> - `main.tf` will contain the main set of configuration for your module. You can also create other configuration files and organize them however makes sense for your project.
> - `variables.tf` will contain the variable definitions for your module. When your module is used by others, the variables will be configured as arguments in the `module` block. Since all Terraform values must be defined, any variables that are not given a default value will become required arguments. Variables with default values can also be provided as module arguments, overriding the default value.
> - `outputs.tf` will contain the output definitions for your module. Module outputs are made available to the configuration using the module, so they are often used to pass information about the parts of your infrastructure defined by the module to other parts of your configuration.
>
> There are also some other files to be aware of, and ensure that you don't distribute them as part of your module:
>
> - `terraform.tfstate` and `terraform.tfstate.backup`: These files contain your Terraform state, and are how Terraform keeps track of the relationship between your configuration and the infrastructure provisioned by it.
> - `.terraform`: This directory contains the modules and plugins used to provision your infrastructure. These files are specific to a specific instance of Terraform when provisioning infrastructure, not the configuration of the infrastructure defined in .tf files.
> - `*.tfvars`: Since module input variables are set via arguments to the `module` block in your configuration, you don't need to distribute any `*.tfvars` files with your module, unless you are also using it as a standalone Terraform configuration.
>
> If you are tracking changes to your module in a version control system, such as git, you will want to configure your version control system to ignore these files. For an example, see this .gitignore file from GitHub.

## Share modules in the private module registry

> ### Create the repository
>
> Fork the [example repository](https://github.com/hashicorp/learn-private-module-aws-s3-webapp) for the webapp module.
>
> In order to publish modules to [the module registry](https://www.terraform.io/docs/cloud/registry/publish.html), module names must have the format `terraform-<PROVIDER>-<NAME>`, where `<NAME>` can contain extra hyphens.
>
> ### Tag a Release
>
> Terraform Cloud modules should be semantically versioned, and pull their versioning information from repository release tags. To publish a module initially, at least one release tag must be present. Tags that don't look like version numbers are ignored. Version tags can optionally be prefixed with a `v`.
>
> ### Import the module
>
> To create a Terraform module for your private module registry, navigate to the Registry header in Terraform Cloud. Choose "Publish private module" from the upper right corner.
>
> Choose the GitHub VCS provider you configured and find the name of the module repository `terraform-aws-s3-webapp`.
>
> Select the module and click the "Publish module" button.
>
> ### Create a configuration that uses the module
>
> Fork the [root configuration repository](https://github.com/hashicorp/learn-private-module-root/). This repository will access the module you created and Terraform will use it to create infrastructure.
>
> ### Create a workspace for the configuration
>
> In Terraform Cloud, create a new workspace and choose your GitHub connection.
>
> Once your configuration is uploaded successfully, choose "Configure variables."
>
> You will need to add the three Terraform variables `prefix`, `region`, and `name`. These variables correspond to the `variables.tf` file in your root module configuration and are necessary to create a unique S3 bucket name for your webapp. Add your AWS credentials as two environment variables, `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` and mark them as sensitive.
>
> ### Deploy the infrastructure
>
> Test your deployment by queuing a plan in your Terraform Cloud UI.

## Add public modules to your private module registry

> As your Terraform usage grows, you may use many Terraform modules to speed up infrastructure development. A growing library of modules can make it hard to find the modules you need and even lead you to accidentally recreate existing modules. The Terraform Cloud (TFC) private module registry (PMR) lets you add both private and public modules to the PMR, so you can more easily find all your modules in one place.
>
> With the PMR, you can maintain a curated list of approved modules for your organization. The PMR becomes the authoritative source for modules that are crucial to your infrastructure and approved for use by your team. It lets you save the modules you use most often, so you can see up-to-date information without having to browse the public module registry.

See the [Terraform Cloud Private Module Registry docs](https://www.terraform.io/docs/cloud/registry/index.html) for further info.

## Refactor monolithic Terraform configuration

> Some Terraform projects start as a monolith, a Terraform project managed by a single main configuration file in a single directory, with a single state file. Small projects may be convenient to maintain this way. However, as your infrastructure grows, restructuring your monolith into logical units will make your Terraform configurations less confusing and safer to manage.

This tutorial explains how to create multiple environments (development and production), and how to configure the environments with either directories or workspaces.

## Module creation - recommended pattern

> When building a module, consider three areas:
>
> 1. **Encapsulation: Group infrastructure that is always deployed together**. Including more infrastructure in a module makes it easier for an end user to deploy that infrastructure but makes the module's purpose and requirements harder to understand.
> 2. **Privileges: Restrict modules to privilege boundaries**. If infrastructure in the module is the responsibility of more than one group, using that module could accidentally violate segregation of duties. Only group resources within privilege boundaries to increase infrastructure segregation and secure your infrastructure.
> 3. **Volatility: Separate long-lived infrastructure from short-lived**. For example, database infrastructure is relatively static while teams could deploy application servers multiple times a day. Managing database infrastructure in the same module as application servers exposes infrastructure that stores state to unnecessary churn and risk.

## Notes

### `module` vs. `resource` blocks

- Terraform modules are re-usable abstractions, composed of resources defined with [`resource` blocks](https://www.terraform.io/docs/language/resources/index.html).
- Terraform modules can be imported and used in other configurations with [`module` blocks](https://www.terraform.io/docs/language/modules/syntax.html).

### Creating modules

[Terraform docs on creating modules](https://www.terraform.io/docs/language/modules/develop/index.html):

> A _module_ is a container for multiple resources that are used together. Modules can be used to create lightweight abstractions, so that you can describe your infrastructure in terms of its architecture, rather than directly in terms of physical objects.
>
> In principle any combination of resources and other constructs can be factored out into a module, but over-using modules can make your overall Terraform configuration harder to understand and maintain, so we recommend moderation.
>
> A good module should raise the level of abstraction by describing a new concept in your architecture that is constructed from resource types offered by providers.
>
> For example, `aws_instance` and `aws_elb` are both resource types belonging to the AWS provider. You might use a module to represent the higher-level concept "HashiCorp Consul cluster running in AWS" which happens to be constructed from these and other AWS provider resources.
>
> We _do not_ recommend writing modules that are just thin wrappers around single other resource types. If you have trouble finding a name for your module that isn't the same as the main resource type inside it, that may be a sign that your module is not creating any new abstraction and so the module is adding unnecessary complexity. Just use the resource type directly in the calling module instead.

### Publishing modules

- **Create a repo with the correct naming syntax for publishing Terraform modules**.
  - Repos containing Terraform modules should be named `terraform-<PROVIDER>-<MODULE>`, where `<MODULE>` can contain extra hyphens. This nomenclature is required to [publish to a module registry](https://www.terraform.io/docs/registry/modules/publish.html).
  - For example, for configurations using the [AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest), the repo name might be `<YOUR_GITHUB_ORG>/terraform-aws-<MODULE>`.
- **Commit the Terraform module to the repo**.
  - See the [Terraform docs on module structure](https://www.terraform.io/docs/language/modules/develop/structure.html) for an explanation of the directory structure.
- **[Connect GitHub and Terraform Cloud](https://www.terraform.io/docs/cloud/vcs/index.html)**.
  - The [GitHub App](https://www.terraform.io/docs/cloud/vcs/github-app.html) is the easiest way to do this for github.com.
  - [Custom OAuth apps](https://www.terraform.io/docs/cloud/vcs/github.html) can also be used.
- **[Publish to a module registry](https://www.terraform.io/docs/registry/modules/publish.html)** to make the Terraform configuration reusable.
  - Public modules can be published to the [Terraform Public Module Registry](https://www.terraform.io/docs/cloud/registry/publish.html).
  - For organizations using Terraform Cloud, modules can be published to the [Private Module Registry](https://www.terraform.io/docs/cloud/registry/index.html) for internal use by the organization.
  - Modules use [semantic versioning](https://semver.org/). Push a Git tag to release a new version.
