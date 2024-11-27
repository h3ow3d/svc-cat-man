locals {
  config     = yamldecode(file("${path.module}/config.yml"))
  portfolios = local.config.portfolios
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

  source                              = "./modules/portfolios"
  template_storage_bucket_id          = aws_s3_bucket.template_storage.id
  template_storage_bucket_domain_name = aws_s3_bucket.template_storage.bucket_domain_name
  name                                = each.value.name
  description                         = each.value.description
  provider_name                       = each.value.provider_name
  products                            = each.value.products
}
