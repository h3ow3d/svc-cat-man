variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "AWS region."
}

variable "portfolios" {
  description = "List of portfolios with their associated products, groups, and policies."
  type = list(object({
    name          = string
    description   = string
    provider_name = string
    groups        = list(string)
    products = list(object({
      name               = string
      owner              = string
      type               = string
      source             = string
      launch_policy_arns = list(string)
    }))
  }))
}
