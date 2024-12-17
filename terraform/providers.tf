provider "aws" {
  region = var.region
}


provider "github" {
  owner = "Infin8L00p"
  app_auth {}
}
