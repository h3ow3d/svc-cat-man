locals {
  config     = yamldecode(file("${path.module}/config.yml"))
  portfolios = local.config.portfolios

  products = flatten([
    for portfolio in local.portfolios : [
      for product in portfolio.products : {
        portfolio_name = portfolio.name
        portfolio_id   = module.portfolios[portfolio.name].portfolio_id
        name           = product.name
        description    = portfolio.description
        owner          = product.owner
        type           = product.type
        version        = product.version
      }
    ]
  ])
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  lower   = true
}

resource "aws_s3_bucket" "template_storage" {
  bucket        = "my-yaml-bucket-${random_string.suffix.result}"
  force_destroy = true

  tags = {
    Name        = "YAML Upload Bucket"
    Environment = "Production"
  }
}

module "portfolios" {
  for_each = { for portfolio in local.portfolios : portfolio.name => portfolio }

  source        = "./modules/portfolio"
  name          = each.value.name
  description   = each.value.description
  provider_name = each.value.provider_name
  principal_arns = [
    "arn:aws:iam::575108940418:group/Admins"
  ]
}

module "products" {
  for_each = { for product in local.products : product.name => product }

  source                              = "./modules/product"
  name                                = each.value.name
  owner                               = each.value.owner
  type                                = each.value.type
  product_version                     = each.value.version
  template_storage_bucket_id          = aws_s3_bucket.template_storage.id
  template_storage_bucket_domain_name = aws_s3_bucket.template_storage.bucket_domain_name
  portfolio_id                        = each.value.portfolio_id
  portfolio_name                      = each.value.portfolio_name
}
