terraform {
  backend "s3" {
    bucket         = "svccatman-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "svccatman-state-lock-table"
    encrypt        = true
  }
}
