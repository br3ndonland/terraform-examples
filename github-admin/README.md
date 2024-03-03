# GitHub administration with the GitHub Terraform provider

## Description

This is an example of how to manage GitHub organizations with the [GitHub Terraform provider](https://registry.terraform.io/providers/integrations/github/latest).

## Organizations

The GitHub Terraform provider can manage [GitHub organization settings](https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/accessing-your-organizations-settings) with the [`github_organization_settings` resource](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_settings).

The configurations in this repo are multi-org capable. The terraform variables in [`variables.tf`](variables.tf) support separate keys for each org so that metadata can be stored in variable defaults if needed.

## Repos

### Creation

To help ensure that all repos are tracked in Terraform state, [repo creation can be restricted](https://docs.github.com/en/organizations/managing-organization-settings/restricting-repository-creation-in-your-organization) to organization owners. New repos can be created by updating `var.repos` and applying the Terraform configurations.

There are special considerations when creating repos with GitHub Pages sites. Repos must be created with a first `terraform apply`, then the `pages` configuration block must be added in a second `terraform apply`. There may also be issues when applying `pages` configurations on pre-existing repos ([integrations/terraform-provider-github#777](https://github.com/integrations/terraform-provider-github/issues/777)). To address these limitations, the `pages` configuration block may move to a separate resource ([integrations/terraform-provider-github#782](https://github.com/integrations/terraform-provider-github/issues/782)).

### Branches

Each new GitHub repo automatically gets a `main` branch. It is common to have other long-running branches as well, such as `develop`, `integration`, `staging`, `production`, etc. To create other branches, branch names for each repo can be passed in to `var.repos` and a branch will be created for each branch name given.

The default branch can be set with `var.repos`.

Each new branch in a GitHub repo is created from a source branch, which defaults to `main`. To specify a different source branch, use "from" in the branch name, like `"new-branch-name from source-branch-name"`, in the list of branches in `var.repos`.

### Rulesets

[Rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets) specify rules for branches and tags. [Repository rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/managing-rulesets-for-a-repository) apply to a single repo and can be managed with the [`github_repository_ruleset` resource](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_ruleset). [Organization rulesets](https://docs.github.com/en/enterprise-cloud@latest/organizations/managing-organization-settings/creating-rulesets-for-repositories-in-your-organization#selecting-branch-or-tag-protections) can apply to multiple repos in an organization and can be managed with the [`github_organization_ruleset` resource](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_ruleset).

[GitHub supports specific rules for each ruleset](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets). For example, [a ruleset can require status checks to pass](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets#require-status-checks-to-pass-before-merging) before merging pull requests. These status checks require a `context` (the name of the check, which is often a GitHub Actions workflow job name), and an `integration_id` (an opaquely-defined identifier that can be obtained from the GitHub API, such as `15368` for GitHub Actions). Multiple rules can be "layered," meaning that multiple rulesets and rules can be used for a given branch or tag. If the same rule is defined multiple times, the most restrictive version applies.

[GitHub has also implemented required workflows in rulesets](https://github.blog/2023-10-11-enforcing-code-reliability-by-requiring-workflows-with-github-repository-rules/), but this has not landed in the GitHub Terraform provider yet for either organization rulesets ([integrations/terraform-provider-github#1970](https://github.com/integrations/terraform-provider-github/issues/1970)) or repository rulesets.

### Branch and tag protection

Prior to introducing rulesets, GitHub offered [branch protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches) and [tag protection](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/managing-repository-settings/configuring-tag-protection-rules). Rulesets have some improved features and are recommended instead.

## Members and collaborators

GitHub organization members are managed with `var.members`, which will create instances of the [`github_membership` resource](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/membership). To help identify members, consider setting the variable key for each member to the member's first and last name (instead of their GitHub username).

Members have [organization roles](https://docs.github.com/en/organizations/managing-peoples-access-to-your-organization-with-roles/roles-in-an-organization). Note that the organization role `owner` shown in the GitHub UI is `admin` in the [GitHub REST API](https://docs.github.com/en/rest/reference/orgs#set-organization-membership-for-a-user) and GitHub Terraform provider ([integrations/terraform-provider-github#886](https://github.com/integrations/terraform-provider-github/issues/886)). The term "owner" is also confusingly used to indicate the user or organization that owns a repo, as seen in [`provider "github"` blocks](https://registry.terraform.io/providers/integrations/github/latest/docs#argument-reference).

GitHub offers an "[outside collaborator](https://docs.github.com/en/organizations/managing-user-access-to-your-organizations-repositories/managing-outside-collaborators/adding-outside-collaborators-to-repositories-in-your-organization)" feature for managing consultants. The Github Terraform provider offers a [`github_repository_collaborator`](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_collaborator) resource that accepts repository, username, and permission. This means that the number of resources is the product of repos and collaborators ([integrations/terraform-provider-github#1060](https://github.com/integrations/terraform-provider-github/issues/1060)). Variables for repos and collaborators are maps of objects/maps, so the variables need to be converted before instantiating resources:

## Teams

GitHub teams can be provisioned with the [`github_team` resource](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team). Members can be added to teams with the [`github_team_membership` resource](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_membership). Repos can be added to teams with the [`github_team_repository` resource](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository).
