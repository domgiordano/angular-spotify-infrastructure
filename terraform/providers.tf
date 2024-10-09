terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.38"
    }
  }
}
provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region     = var.aws_region
}
