provider "aws" {
  region = var.region
}


provider "github" {
  owner = "h3ow3d"
  app_auth {
    installation_id=var.github_app_installation_id
    pem_file=file(var.github_app_pem_file)
  }
}
