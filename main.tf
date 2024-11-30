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
