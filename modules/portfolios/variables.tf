variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "provider_name" {
  type = string
}

variable "template_storage_bucket_id" {
  type = string
}

variable "template_storage_bucket_domain_name" {
  type = string
}

variable "products" {
  type = list(object({
    name    = string
    owner   = string
    type    = string
    version = string
  }))
}
