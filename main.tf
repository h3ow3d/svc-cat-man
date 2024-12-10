locals {
  config     = yamldecode(file("${path.module}/config.yml"))
  portfolios = local.config.portfolios
  base_product_template_path = "cloudformation/template.yaml"

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
  bucket        = lower("product-template-storage-${random_string.suffix.result}")
  force_destroy = true

  tags = {
    Name        = "Storage for Service Catalog Product templates."
  }
}

resource "aws_s3_object" "base_product_template" {
  bucket = aws_s3_bucket.product_template_storage.id
  key    = "template.yaml"
  source = local.base_product_template_path

  etag = filemd5(local.base_product_template_path)
}

module "portfolios" {
  for_each = { for portfolio in local.portfolios : portfolio.name => portfolio }

  source        = "./modules/portfolio"
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
  name                                        = each.value.name
  owner                                       = each.value.owner
  environments                                = var.environments
  type                                        = each.value.type
  product_version                             = each.value.version
  product_template_storage_bucket_domain_name = aws_s3_bucket.product_template_storage.bucket_domain_name
  portfolio_id                                = each.value.portfolio_id
  portfolio_name                              = each.value.portfolio_name
  launch_policy_arns                          = each.value.launch_policy_arns
  base_template_path = local.base_product_template_path
}
