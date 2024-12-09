variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "AWS region."
}

variable "environment" {
  type = string
  default = "development"
}
