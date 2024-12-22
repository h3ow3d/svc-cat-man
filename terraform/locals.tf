locals {
  # Use the Terraform variable directly instead of reading from a file
  portfolios = var.portfolios

  products = flatten([
    for portfolio in local.portfolios : [
      for product in portfolio.products : {
        portfolio_name     = portfolio.name
        portfolio_id       = module.portfolios[portfolio.name].portfolio_id
        name               = product.name
        description        = portfolio.description
        owner              = product.owner
        type               = product.type
        source             = product.source
        launch_policy_arns = product.launch_policy_arns
      }
    ]
  ])

  product_template_storage_bucket_name = lower("product-template-storage-${random_string.suffix.result}")
}
