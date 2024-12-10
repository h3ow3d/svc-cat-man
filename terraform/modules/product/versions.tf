terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.78.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}
