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

resource "aws_servicecatalog_principal_portfolio_association" "portfolio_group_association" {
  portfolio_id  = aws_servicecatalog_portfolio.portfolio.id
  principal_arn = aws_iam_group.portfolio_group.arn
}

resource "aws_iam_group" "portfolio_group" {
  name = "${var.environment}-${var.name}"
  path = "/service_catalog/"
}

resource "aws_iam_group_policy_attachment" "portfolio_usage_policies" {
  for_each = toset(var.policy_arns)

  group      = aws_iam_group.portfolio_group.name
  policy_arn = each.value
}
