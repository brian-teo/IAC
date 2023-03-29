terraform {
  source = "../modules"
}

remote_state {
  backend = "s3"
  config = {
    bucket  = "dev-teo-statefiles"
    key     = "${path_relative_to_include()}/dev-mainmodules-terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}


inputs = {
  environment                = "dev"
  service_name_base          = "vpc"
  service_name               = "dev-vpc"
  vpc_cidr_block             = "10.0.0.0/16"
  avail_zones                = ["eu-north-1a","eu-north-1b"]
  vpc_private_subnets        = ["10.0.7.0/24", "10.0.8.0/24"]
  vpc_public_subnets         = ["10.0.17.0/24", "10.0.18.0/24"]
  vpc_database_subnets       = ["10.0.27.0/24", "10.0.28.0/24"]
  
  tags                           = {
    Environment = "dev"
    Application = "teoricentralen"
    Service     = "teoricentralen"
  }
}
