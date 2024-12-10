variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "AWS region."
}

variable "environment" {
  type = string
  default = "development"
}

variable github_organisation {
  type        = string
  default     = "h3ow3d"
}

variable github_app_installation_id {
  type        = string
}

variable github_app_pem_file {
  type        = string
}
