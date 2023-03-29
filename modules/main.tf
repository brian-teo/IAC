locals {

  environment          = var.environment
  service_name         = var.service_name
  vpc_cidr_block       = var.vpc_cidr_block
  avail_zones          = var.avail_zones
  vpc_private_subnets  = var.vpc_private_subnets
  vpc_public_subnets   = var.vpc_public_subnets
  vpc_database_subnets = var.vpc_database_subnets

  tags = var.tags
}

terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.30.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }

}








