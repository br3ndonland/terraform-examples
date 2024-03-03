locals {
  advanced_security = (
    lookup(var.organization_settings, var.owner, null) != null
    ? var.organization_settings[var.owner].advanced_security
    : false
  )
  organization_settings = {
    for key, value in var.organization_settings :
    key => value if key == var.owner
  }
  repo_branch_names = {
    for key, value in lookup(var.repos, var.owner, {}) :
    key => toset([for branch_name in value.protected_branch_names : branch_name])
    if value.protected_branch_names != null
  }
  repo_branch_configurations = merge([
    for key, branch_names in local.repo_branch_names : {
      for branch_name in branch_names : "${key}-${replace(branch_name, "/[\\*\\s].*/", "")}" => {
        branch         = replace(branch_name, "/[\\*\\s].*/", "")
        source_branch  = strcontains(branch_name, " from ") ? split(" from ", branch_name)[1] : "main"
        repository     = var.repos[var.owner][key].name
        repository_key = key
      }
    }
  ]...)
}

# organization

resource "github_organization_settings" "org" {
  for_each                                                     = local.organization_settings
  advanced_security_enabled_for_new_repositories               = local.advanced_security
  billing_email                                                = each.value.billing_email
  default_repository_permission                                = each.value.default_repository_permission
  dependabot_alerts_enabled_for_new_repositories               = true
  dependabot_security_updates_enabled_for_new_repositories     = true
  dependency_graph_enabled_for_new_repositories                = true
  has_organization_projects                                    = true
  has_repository_projects                                      = false
  members_can_create_internal_repositories                     = false
  members_can_create_pages                                     = true
  members_can_create_private_pages                             = true
  members_can_create_private_repositories                      = false
  members_can_create_public_pages                              = false
  members_can_create_public_repositories                       = false
  members_can_create_repositories                              = false
  members_can_fork_private_repositories                        = false
  secret_scanning_enabled_for_new_repositories                 = each.value.advanced_security
  secret_scanning_push_protection_enabled_for_new_repositories = each.value.advanced_security
}

# repos

resource "github_repository" "repo" {
  for_each                    = lookup(var.repos, var.owner, {})
  name                        = each.value.name
  description                 = each.value.description
  homepage_url                = each.value.homepage_url
  topics                      = each.value.topics
  visibility                  = each.value.visibility
  gitignore_template          = each.value.gitignore_template
  is_template                 = each.value.is_repo_template
  allow_auto_merge            = false
  allow_merge_commit          = each.value.allow_merge_commit
  allow_rebase_merge          = each.value.allow_rebase_merge
  allow_squash_merge          = each.value.allow_squash_merge
  allow_update_branch         = true
  auto_init                   = true
  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "PR_BODY"
  delete_branch_on_merge      = true
  has_discussions             = each.value.has_discussions
  has_issues                  = each.value.has_issues
  has_projects                = false
  has_wiki                    = false
  vulnerability_alerts = (
    each.value.has_vulnerability_alerts == true || each.value.visibility == "public"
    ? true
    : false
  )
  dynamic "security_and_analysis" {
    for_each = local.advanced_security == true ? [""] : []
    content {
      advanced_security {
        status = "enabled"
      }
      secret_scanning {
        status = "enabled"
      }
      secret_scanning_push_protection {
        status = "enabled"
      }
    }
  }
  dynamic "pages" {
    for_each = each.value.enable_github_pages == true ? [""] : []
    content {
      build_type = "workflow"
      cname      = each.value.github_pages_cname
    }
  }
  dynamic "template" {
    for_each = each.value.from_repo_template != null ? [""] : []
    content {
      include_all_branches = false
      owner                = split("/", each.value.from_repo_template)[0]
      repository           = split("/", each.value.from_repo_template)[1]
    }
  }
}

resource "github_branch" "branch" {
  depends_on = [github_repository.repo]
  for_each = {
    for key, value in local.repo_branch_configurations :
    key => value if value.branch != "main"
  }
  branch        = each.value.branch
  source_branch = each.value.source_branch
  repository    = each.value.repository
}

resource "github_branch_default" "default" {
  depends_on = [github_repository.repo, github_branch.branch]
  for_each   = lookup(var.repos, var.owner, {})
  repository = each.value.name
  branch     = each.value.default_branch_name
}

resource "github_repository_ruleset" "branch_create" {
  depends_on  = [github_repository.repo, github_branch.branch]
  for_each    = local.repo_branch_configurations
  enforcement = "active"
  name        = "branch-create-${each.value.branch}"
  repository  = each.value.repository
  target      = "branch"
  bypass_actors {
    actor_id    = 5 # repository admin
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }
  bypass_actors {
    actor_id    = 2 # repository maintainer
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }
  dynamic "bypass_actors" {
    for_each = local.organization_settings
    content {
      actor_id    = 1
      actor_type  = "OrganizationAdmin"
      bypass_mode = "always"
    }
  }
  conditions {
    ref_name {
      exclude = []
      include = ["refs/heads/${each.value.branch}"]
    }
  }
  rules {
    creation = true
  }
}

resource "github_repository_ruleset" "branch_delete" {
  depends_on  = [github_repository.repo, github_branch.branch]
  for_each    = local.repo_branch_configurations
  enforcement = "active"
  name        = "branch-delete-${each.value.branch}"
  repository  = each.value.repository
  target      = "branch"
  bypass_actors {
    actor_id    = 5 # repository admin
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }
  dynamic "bypass_actors" {
    for_each = local.organization_settings
    content {
      actor_id    = 1
      actor_type  = "OrganizationAdmin"
      bypass_mode = "always"
    }
  }
  conditions {
    ref_name {
      exclude = []
      include = ["refs/heads/${each.value.branch}"]
    }
  }
  rules {
    deletion = true
  }
}

resource "github_repository_ruleset" "branch_update" {
  depends_on  = [github_repository.repo, github_branch.branch]
  for_each    = local.repo_branch_configurations
  enforcement = "active"
  name        = "branch-update-${each.value.branch}"
  repository  = each.value.repository
  target      = "branch"
  bypass_actors {
    actor_id    = 5 # repository admin
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }
  bypass_actors {
    actor_id    = 2 # repository maintainer
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }
  dynamic "bypass_actors" {
    for_each = local.organization_settings
    content {
      actor_id    = 1
      actor_type  = "OrganizationAdmin"
      bypass_mode = "always"
    }
  }
  conditions {
    ref_name {
      exclude = []
      include = ["refs/heads/${each.value.branch}"]
    }
  }
  rules {
    non_fast_forward        = true
    required_linear_history = true
    required_signatures = (
      var.repos[var.owner][each.value.repository_key].required_signatures != null
      ? var.repos[var.owner][each.value.repository_key].required_signatures[each.value.branch]
      : false
    )
    update = true
    pull_request {
      required_approving_review_count = (
        var.repos[var.owner][each.value.repository_key].required_approving_review_count != null
        ? var.repos[var.owner][each.value.repository_key].required_approving_review_count[each.value.branch]
        : 1
      )
      require_code_owner_review  = true
      require_last_push_approval = true
    }
    dynamic "required_deployments" {
      for_each = {
        for key, value in var.repos[var.owner] :
        key => toset(lookup(value.required_deployments, each.value.branch, []))
        if value.name == each.value.repository
        && value.required_deployments != null
      }
      content {
        required_deployment_environments = required_deployments.value
      }
    }
    dynamic "required_status_checks" {
      for_each = {
        for key, value in var.repos[var.owner] :
        key => toset(lookup(value.required_status_checks, each.value.branch, []))
        if value.name == each.value.repository
        && value.required_status_checks != null
      }
      content {
        dynamic "required_check" {
          for_each = required_status_checks.value
          content {
            context        = required_check.value.context
            integration_id = required_check.value.integration_id
          }
        }
        strict_required_status_checks_policy = true
      }
    }
  }
}

resource "github_repository_ruleset" "tag_create" {
  for_each    = github_repository.repo
  enforcement = "active"
  name        = "tag create"
  repository  = each.value.name
  target      = "tag"
  bypass_actors {
    actor_id    = 5 # repository admin
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }
  bypass_actors {
    actor_id    = 2 # repository maintainer
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }
  dynamic "bypass_actors" {
    for_each = local.organization_settings
    content {
      actor_id    = 1
      actor_type  = "OrganizationAdmin"
      bypass_mode = "always"
    }
  }
  conditions {
    ref_name {
      exclude = []
      include = ["~ALL"]
    }
  }
  rules {
    creation            = true
    required_signatures = true
  }
}

resource "github_repository_ruleset" "tag_delete" {
  for_each    = github_repository.repo
  enforcement = "active"
  name        = "tag delete"
  repository  = each.value.name
  target      = "tag"
  bypass_actors {
    actor_id    = 5 # repository admin
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }
  dynamic "bypass_actors" {
    for_each = local.organization_settings
    content {
      actor_id    = 1
      actor_type  = "OrganizationAdmin"
      bypass_mode = "always"
    }
  }
  conditions {
    ref_name {
      exclude = []
      include = ["~ALL"]
    }
  }
  rules {
    deletion = true
    update   = true
  }
}

resource "github_repository_collaborator" "outside_collaborator" {
  depends_on = [github_repository.repo]
  for_each   = lookup(var.outside_collaborators, var.owner, {})
  permission = each.value.permission
  repository = each.value.repository
  username   = each.value.username
}

# members

resource "github_membership" "member" {
  for_each = lookup(var.members, var.owner, {})
  username = each.value.username
  role     = each.value.role == "admin" ? "admin" : "member"
}

# teams

resource "github_team" "contributors" {
  name        = "contributors"
  description = "Members of this team get write access to selected repositories"
  privacy     = "closed"
}

resource "github_team" "maintainers" {
  name        = "maintainers"
  description = "Members of this team get maintain access to selected repositories and write access to other repositories"
  privacy     = "closed"
}

resource "github_team_membership" "contributors" {
  depends_on = [github_membership.member]
  for_each = toset([
    for member in lookup(var.members, var.owner, {}) :
    member.username if member.role == "contributor"
  ])
  team_id  = github_team.contributors.id
  username = each.value
  role     = "member"
}

resource "github_team_membership" "maintainers" {
  depends_on = [github_membership.member]
  for_each = toset([
    for member in lookup(var.members, var.owner, {}) :
    member.username if member.role == "maintainer"
  ])
  team_id  = github_team.maintainers.id
  username = each.value
  role     = "member"
}

resource "github_team_repository" "contributors_push" {
  for_each = toset([
    for repo in github_repository.repo :
    repo.name if contains(var.repos_for_team_contributors[var.owner], repo.name)
  ])
  team_id    = github_team.contributors.id
  repository = each.value
  permission = "push"
}

resource "github_team_repository" "maintainers_maintain" {
  for_each = toset([
    for repo in github_repository.repo :
    repo.name if contains(var.repos_for_team_maintainers[var.owner], repo.name)
  ])
  team_id    = github_team.maintainers.id
  repository = each.value
  permission = "maintain"
}

resource "github_team_repository" "maintainers_push" {
  for_each = toset([
    for repo in github_repository.repo :
    repo.name if !contains(var.repos_for_team_maintainers[var.owner], repo.name)
  ])
  team_id    = github_team.maintainers.id
  repository = each.value
  permission = "push"
}
