variable "owner" {
  description = "GitHub owner (user or organization) for the workspace"
  type        = string
}

variable "token" {
  description = "GitHub Personal Access Token (PAT) for org admin"
  sensitive   = true
  type        = string
}

variable "organization_settings" {
  description = "GitHub organization settings"
  type = map(object({
    advanced_security             = optional(bool, false)
    billing_email                 = string
    default_repository_permission = optional(string, "none")
  }))
  default = {
    org-1 = {
      advanced_security               = true
      billing_email                   = "you@example.com"
      configure_organization_settings = true
      default_repository_permission   = "read"
    }
    org-2 = {
      billing_email                 = "you@example.com"
      default_repository_permission = "write"
    }
  }
}

variable "repos" {
  description = "Map of configuration attributes for each github_repository resource"
  type = map(map(object({
    name                            = string
    visibility                      = string
    description                     = optional(string)
    gitignore_template              = optional(string)
    is_repo_template                = optional(bool, false)
    from_repo_template              = optional(string)
    topics                          = optional(list(string))
    allow_merge_commit              = optional(bool, false)
    allow_rebase_merge              = optional(bool, false)
    allow_squash_merge              = optional(bool, true)
    enable_github_pages             = optional(bool, false)
    github_pages_cname              = optional(string)
    has_discussions                 = optional(bool, false)
    has_issues                      = optional(bool, false)
    has_vulnerability_alerts        = optional(bool)
    homepage_url                    = optional(string)
    default_branch_name             = optional(string, "main")
    protected_branch_names          = optional(list(string))
    required_approving_review_count = optional(map(number))
    required_deployments            = optional(map(list(string)))
    required_signatures             = optional(map(bool))
    required_status_checks = optional(map(list(object({
      context        = string
      integration_id = optional(number, 0)
    }))))
  })))
  default = {
    org-1 = {
      example-repo-1 = {
        name                = "example-repo-1"
        visibility          = "private"
        default_branch_name = "development"
        protected_branch_names = [
          "development",
          "production",
          "staging",
        ]
        required_signatures = {
          development = true
          production  = true
          staging     = true
        }
        required_status_checks = {
          development = [
            { context = "code-quality-checks", integration_id = 15368 },
            { context = "pr-checks", integration_id = 15368 },
            { context = "tests", integration_id = 15368 },
          ]
          production = [
            { context = "code-quality-checks", integration_id = 15368 },
            { context = "deployment-to-development-environment", integration_id = 15368 },
            { context = "deployment-to-staging-environment", integration_id = 15368 },
            { context = "tests", integration_id = 15368 },
          ]
          staging = [
            { context = "code-quality-checks", integration_id = 15368 },
            { context = "deployment-to-development-environment", integration_id = 15368 },
            { context = "tests", integration_id = 15368 },
          ]
        }
      }
      example-repo-2 = {
        name                = "ExampleRepo2"
        visibility          = "private"
        default_branch_name = "develop"
        protected_branch_names = [
          "develop",
          "main",
        ]
      }
      example-repo-3 = {
        name       = "example-repo-3"
        visibility = "private"
      }
    }
    org-2 = {}
  }
}

variable "members" {
  description = "GitHub organization members"
  type = map(map(object({
    username = string
    role     = string
  })))
  default = {
    org-1 = {
      member-name = {
        username = "example-username"
        role     = "member"
      }
    }
    org-2 = {
      member-name = {
        username = "example-username"
        role     = "member"
      }
    }
  }
}

variable "outside_collaborators" {
  description = "GitHub organization outside collaborators"
  type = map(map(object({
    permission = optional(string, "push")
    repository = string
    username   = string
  })))
  default = {
    org-1 = {
      collaborator-name-repo-name = {
        permission = "pull"
        repository = "example-repo-name"
        username   = "collaborator-name"
      }
    }
    org-2 = {
      collaborator-name-repo-name = {
        permission = "maintain"
        repository = "example-repo-name"
        username   = "collaborator-name"
      }
    }
  }
}

variable "repos_for_team_contributors" {
  description = "Repos to which the contributors team will grant access"
  type        = map(set(string))
  default = {
    org-1 = ["example-repo-1", "example-repo-2"]
    org-2 = []
  }
}

variable "repos_for_team_maintainers" {
  description = "Repos to which the maintainers team will grant access"
  type        = map(set(string))
  default = {
    org-1 = ["example-repo-1", "example-repo-2"]
    org-2 = []
  }
}
