terraform {
  backend "s3" {
    bucket         = "svc-cat-man-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "svc-cat-man-state-lock-table"
    encrypt        = true
  }
}
