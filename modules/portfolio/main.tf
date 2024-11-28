resource "aws_servicecatalog_portfolio" "portfolio" {
  name          = "${var.environment}-${var.name}"
  description   = var.description
  provider_name = var.provider_name
}

resource "aws_servicecatalog_principal_portfolio_association" "principal_association" {
  for_each = toset(var.principal_arns)

  portfolio_id  = aws_servicecatalog_portfolio.portfolio.id
  principal_arn = each.value
}
