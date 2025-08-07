terraform {
  required_version = ">= 1.9.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.7.0"
    }
  }

  backend "local" {
    path = ".state-files/terraform.tfstate"
  }

}

provider "aws" {
  region = var.region
}