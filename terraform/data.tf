data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "codeconnection_arn" {
  name = "codeconnection_arn"
}

data "aws_ssm_parameter" "github_organisation" {
  name = "github_organisation"
}

data "aws_ssm_parameter" "github_repository" {
  name = "github_repository"
}
