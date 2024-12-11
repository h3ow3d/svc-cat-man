variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "AWS region."
}

variable "environments" {
  type    = list(any)
  default = ["development", "production"]
}
