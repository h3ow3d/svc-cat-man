resource "aws_servicecatalog_portfolio" "portfolio" {
  name          = var.name
  description   = var.description
  provider_name = var.provider_name
}

resource "aws_servicecatalog_product" "product" {
  for_each = { for product in var.products : product.name => product }

  name  = each.value.name
  owner = each.value.owner
  type  = each.value.type

  provisioning_artifact_parameters {
    name         = each.value.version
    template_url = "https://${var.template_storage_bucket_domain_name}/${each.value.name}.yml"
    type         = each.value.type
  }
}

resource "aws_s3_object" "template_artifact" {
  for_each = { for product in var.products : product.name => product }

  bucket = var.template_storage_bucket_id
  key    = "${each.value.name}.yml"
  source = "${path.cwd}/portfolios/${var.name}/${each.value.name}.yml"
  etag   = filemd5("${path.cwd}/portfolios/${var.name}/${each.value.name}.yml")
}
