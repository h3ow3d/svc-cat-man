locals {
  product_template_filename  = "${var.name}.yml"
  product_template_full_path = "${path.cwd}/portfolios/${var.portfolio_name}/${local.product_template_filename}"
}

resource "aws_servicecatalog_product" "product" {
  name  = "${var.environment}-${var.name}"
  owner = var.owner
  type  = var.type

  provisioning_artifact_parameters {
    name         = var.product_version
    template_url = "https://${var.template_storage_bucket_domain_name}/${local.product_template_filename}"
    type         = var.type
  }
}

resource "aws_s3_object" "template_artifact" {
  bucket = var.template_storage_bucket_id
  key    = "${var.name}.yml"
  source = local.product_template_full_path
  etag   = filemd5(local.product_template_full_path)
}

resource "aws_servicecatalog_product_portfolio_association" "association" {
  portfolio_id = var.portfolio_id
  product_id   = aws_servicecatalog_product.product.id
}
