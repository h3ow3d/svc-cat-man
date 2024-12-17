locals {
  environments = ["main", "development", "production"]
}

resource "github_repository" "product_repository" {
  # checkov:skip=CKV2_GIT_1:Ensure each Repository has branch protection associated
  name        = var.name
  description = "Service Catalog product: ${var.name}"

  visibility           = "private"
  vulnerability_alerts = true
  auto_init            = true
}

resource "github_branch" "branch" {
  for_each = toset(local.environments)

  repository = github_repository.product_repository.name
  branch     = each.value
}

resource "github_branch_default" "default" {
  depends_on = [
    github_branch.branch["main"]
  ]

  repository = github_repository.product_repository.name
  branch     = local.environments[0]
}

resource "github_repository_file" "base_template" {
  depends_on = [
    github_branch.branch["main"]
  ]

  repository          = github_repository.product_repository.name
  branch              = local.environments[0]
  file                = "template.yaml"
  content             = file("${path.module}/cloudformation/template.yaml")
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = false
  autocreate_branch   = true
}
