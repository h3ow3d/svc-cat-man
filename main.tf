locals {
  config     = yamldecode(file("${path.module}/config.yml"))
  portfolios = local.config.portfolios
}

resource "aws_servicecatalog_portfolio" "portfolio" {
  for_each = { for portfolio in local.portfolios : portfolio.name => portfolio }

  name          = each.value.name
  description   = each.value.description
  provider_name = each.value.provider_name
}
