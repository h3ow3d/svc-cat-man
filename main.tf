locals {
  config     = yamldecode(file("${path.module}/env/${var.environment}/config.yml"))
  portfolios = local.config.portfolios

  products = flatten([
    for portfolio in local.portfolios : [
      for product in portfolio.products : {
        portfolio_name     = portfolio.name
        portfolio_id       = module.portfolios[portfolio.name].portfolio_id
        name               = product.name
        description        = portfolio.description
        owner              = product.owner
        type               = product.type
        version            = product.version
        launch_policy_arns = product.launch_policy_arns
      }
    ]
  ])
}

data "aws_caller_identity" "current" {}

resource "random_string" "suffix" {
  length  = 6
  special = false
}

resource "aws_s3_bucket" "product_template_storage" {
  # checkov:skip=CKV2_AWS_62:Ensure S3 buckets should have event notifications enable
  # checkov:skip=CKV2_AWS_6:Ensure that S3 bucket has a Public Access block
  # checkov:skip=CKV2_AWS_61:Ensure that an S3 bucket has a lifecycle configuration
  # checkov:skip=CKV_AWS_18:Ensure the S3 bucket has access logging enabled
  # checkov:skip=CKV_AWS_145:Ensure that S3 buckets are encrypted with KMS by default
  # checkov:skip=CKV_AWS_144:Ensure that S3 bucket has cross-region replication enabled
  # checkov:skip=CKV_AWS_21:Ensure all data stored in the S3 bucket have versioning enabled
  bucket        = lower("${var.environment}-product-template-storage-${random_string.suffix.result}")
  force_destroy = true

  tags = {
    Name        = "Storage for Service Catalog Product templates."
    Environment = var.environment
  }
}

module "portfolios" {
  for_each = { for portfolio in local.portfolios : portfolio.name => portfolio }

  source        = "./modules/portfolio"
  environment   = var.environment
  name          = each.value.name
  description   = each.value.description
  provider_name = each.value.provider_name

  principal_arns = [
    for group in each.value.groups :
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:group/${group}"
  ]
}

module "products" {
  for_each = { for product in local.products : product.name => product }

  source                                      = "./modules/product"
  environment                                 = var.environment
  name                                        = each.value.name
  owner                                       = each.value.owner
  type                                        = each.value.type
  product_version                             = each.value.version
  product_template_storage_bucket_id          = aws_s3_bucket.product_template_storage.id
  product_template_storage_bucket_domain_name = aws_s3_bucket.product_template_storage.bucket_domain_name
  portfolio_id                                = each.value.portfolio_id
  portfolio_name                              = each.value.portfolio_name
  launch_policy_arns                          = each.value.launch_policy_arns
}


data "github_repository" "example" {
  full_name = "h3ow3d/svc-cat-man"
}

output "github_repository" {
  value       = "${data.github_repository.example.repo_id}"
}

resource "github_repository" "example" {
  # checkov:skip=CKV2_GIT_1:Ensure each Repository has branch protection associated
  name        = "${var.environment}-h3ow3d"
  description = "My awesome codebase"

  visibility = "private"
  vulnerability_alerts = true
}
