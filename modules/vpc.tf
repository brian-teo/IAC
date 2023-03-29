
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.19"

  name = local.service_name
  cidr = local.vpc_cidr_block

  azs              = local.avail_zones
  private_subnets  = local.vpc_private_subnets
  public_subnets   = local.vpc_public_subnets
  database_subnets = local.vpc_database_subnets

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  enable_ipv6          = false

  tags = local.tags
}

module "endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 3.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc_allow_endpoint_https.security_group_id]
  subnet_ids         = module.vpc.private_subnets

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
    }
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      security_group_ids  = [module.vpc_allow_endpoint_https.security_group_id]
    }
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true
      security_group_ids  = [module.vpc_allow_endpoint_https.security_group_id]
    }
    ec2 = {
      service             = "ec2"
      private_dns_enabled = true
      security_group_ids  = [module.vpc_allow_endpoint_https.security_group_id]
    }
    ec2messages = {
      service             = "ec2messages"
      private_dns_enabled = true
      security_group_ids  = [module.vpc_allow_endpoint_https.security_group_id]
    }
    kms = {
      service             = "kms"
      private_dns_enabled = true
      security_group_ids  = [module.vpc_allow_endpoint_https.security_group_id]
    }
    logs = {
      service             = "logs"
      private_dns_enabled = true
      security_group_ids  = [module.vpc_allow_endpoint_https.security_group_id]
    }

  }
  tags = local.tags
}


module "vpc_allow_endpoint_https" {
  source              = "terraform-aws-modules/security-group/aws//modules/https-443"
  version             = "~> 4.0"
  vpc_id              = module.vpc.vpc_id
  name                = "${local.service_name}-endpoint-https"
  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  tags                = local.tags
}


resource "aws_db_subnet_group" "this" {
  name        = lower("${local.environment}-mysql-rds-subnet-group")
  description = "${local.environment} mysql subnet group"
  subnet_ids  = module.vpc.database_subnets
  tags        = local.tags
}
