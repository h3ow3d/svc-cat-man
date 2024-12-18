variable "name" {
  type = string
}

variable "product_owner" {
  type = string
}

variable "product_type" {
  type = string
}

variable "product_version" {
  type = string
}

variable "product_template_storage_bucket_domain_name" {
  type = string
}

variable "portfolio_id" {
  type = string
}

variable "launch_policy_arns" {
  type = list(string)
}

variable "product_template_storage_bucket_name" {
  type = string
}

variable "product_source" {
  type = string
}
