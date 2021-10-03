provider "aws" {
  region = local.region
}

terraform {
  backend "local" {
    path = "./tfgoat-aws.tfstate"
  }
}
