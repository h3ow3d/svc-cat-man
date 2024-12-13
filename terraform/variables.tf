variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "AWS region."
}

variable "environments" {
  type    = list(any)
  default = ["development", "production"]
}

variable "github_aws_connector_app_id" {
  type        = string
  description = "AWS Connector for Github Application ID."
}
