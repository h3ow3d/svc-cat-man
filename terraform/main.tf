resource "random_string" "suffix" {
  length  = 6
  special = false
}

resource "aws_s3_bucket" "product_template_storage" {
  # checkov:skip=CKV2_AWS_62:Ensure S3 buckets should have event notifications enabled
  # checkov:skip=CKV2_AWS_6:Ensure that S3 bucket has a Public Access block
  # checkov:skip=CKV2_AWS_61:Ensure that an S3 bucket has a lifecycle configuration
  # checkov:skip=CKV_AWS_18:Ensure the S3 bucket has access logging enabled
  # checkov:skip=CKV_AWS_145:Ensure that S3 buckets are encrypted with KMS by default
  # checkov:skip=CKV_AWS_144:Ensure that S3 bucket has cross-region replication enabled
  # checkov:skip=CKV_AWS_21:Ensure all data stored in the S3 bucket have versioning enabled
  bucket = local.product_template_storage_bucket_name

  tags = {
    Name = "Storage for Service Catalog Product templates."
  }
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
  product_owner                               = each.value.owner
  product_type                                = each.value.type
  product_source                              = each.value.source
  product_template_storage_bucket_name        = local.product_template_storage_bucket_name
  product_template_storage_bucket_domain_name = aws_s3_bucket.product_template_storage.bucket_domain_name
  portfolio_id                                = each.value.portfolio_id
  launch_policy_arns                          = each.value.launch_policy_arns
}

module "cloud_formation_product_pipeline" {
  for_each = {
    for product in local.products : product.name => product
    if product.type == "CLOUD_FORMATION_TEMPLATE"
  }

  source                = "./modules/cloud_formation_product_pipeline"
  name                  = each.value.name
  product_source        = each.value.source
  product_id            = module.products[each.key].product_id
  product_arn           = module.products[each.key].product_arn
  github_connection_arn = data.aws_ssm_parameter.codeconnection_arn.value
  github_repository     = data.aws_ssm_parameter.github_repository.value
  github_organisation   = data.aws_ssm_parameter.github_organisation.value
}
