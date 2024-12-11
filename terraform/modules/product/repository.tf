resource "github_repository" "product_repository" {
  # checkov:skip=CKV2_GIT_1:Ensure each Repository has branch protection associated
  name        = var.name
  description = "Service Catalog product: ${var.name}"

  visibility           = "private"
  vulnerability_alerts = true
}

resource "github_repository_file" "readme" {
  repository     = github_repository.product_repository.name
  file           = "README.md"
  content        = "# Example Bucket"
  commit_message = "Initial commit"
}

resource "github_repository_file" "base_template" {
  for_each            = toset(var.environments)
  repository          = github_repository.product_repository.name
  branch              = each.value
  file                = "template.yaml"
  content             = file(var.base_template_path)
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = false
  autocreate_branch   = true
}
