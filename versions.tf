terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.78.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.5.7"
}
