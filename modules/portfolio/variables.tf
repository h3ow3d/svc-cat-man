variable "environment" {
  type = string
}


variable "name" {
  description = "The name of the portfolio"
  type        = string
}

variable "description" {
  description = "The description of the portfolio"
  type        = string
}

variable "provider_name" {
  description = "The provider name for the portfolio"
  type        = string
}

variable "principal_arns" {
  description = "A list of ARNs for principals to associate with the portfolio"
  type        = list(string)
}
