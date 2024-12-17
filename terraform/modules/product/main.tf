resource "aws_iam_role" "product_launch_role" {
  name = "${var.name}-launch-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowAssumeRoleServiceCatalog"
        Principal = {
          Service = "servicecatalog.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_launch_policies" {
  for_each   = toset(var.launch_policy_arns)
  role       = aws_iam_role.product_launch_role.name
  policy_arn = each.value
}

resource "aws_servicecatalog_constraint" "launch" {
  description  = "Launch constraints"
  portfolio_id = var.portfolio_id
  product_id   = aws_servicecatalog_product.product.id
  type         = "LAUNCH"

  parameters = jsonencode({
    "RoleArn" : aws_iam_role.product_launch_role.arn
  })
}

resource "aws_s3_object" "object" {
  bucket = var.product_template_storage_bucket_name
  key    = "${var.name}.yaml"
  source = "${path.module}/cloudformation/template.yaml"

  etag = filemd5("${path.module}/cloudformation/template.yaml")
}

resource "aws_servicecatalog_product" "product" {
  name  = var.name
  owner = var.product_owner
  type  = var.type

  provisioning_artifact_parameters {
    name         = var.product_version
    template_url = "https://${var.product_template_storage_bucket_domain_name}/${var.name}.yaml"
    type         = var.type
  }
}

resource "aws_servicecatalog_product_portfolio_association" "association" {
  portfolio_id = var.portfolio_id
  product_id   = aws_servicecatalog_product.product.id
}
