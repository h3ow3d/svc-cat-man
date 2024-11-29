output "portfolio_id" {
  description = "The ID of the created portfolio"
  value       = aws_servicecatalog_portfolio.portfolio.id
}

output "portfolio_group_arn" {
  description = "The arn of the portfolio's associated group."
  value       = aws_iam_group.portfolio_group.arn
}
