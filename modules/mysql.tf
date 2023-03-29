locals {
  identifier_name       = "teoricentralen-db-${local.environment}"
  engine                = "mysql"
  engine_version        = "8.0"
  family                = "mysql8.0" # DB parameter group
  major_engine_version  = "8.0"      # DB option group
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 100
  port                  = 3306
}
################################################################################
# Master DB
################################################################################

module "master" {
  source = "terraform-aws-modules/rds/aws"
  version               = "5.1.1"
  identifier            = "${local.identifier_name}-master"
  engine                = local.engine
  engine_version        = local.engine_version
  family                = local.family
  major_engine_version  = local.major_engine_version
  instance_class        = local.instance_class
  allocated_storage     = local.allocated_storage
  max_allocated_storage = local.max_allocated_storage

  db_name                = replace("${local.identifier_name}", "-", "")
  username               = var.db_user
  password               = var.db_password
  create_random_password = false
  port                   = local.port

  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.this.id
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]

  # Backups are required in order to create a replica
  backup_retention_period = 3
  skip_final_snapshot     = true
  # TODO this should be true for prod
  deletion_protection     = false
  storage_encrypted       = true

  tags = local.tags
}
################################################################################
# Replica DB
################################################################################

module "replica" {

  source = "terraform-aws-modules/rds/aws"
  version               = "5.1.1"
  identifier = "${local.identifier_name}-replica"

  # Source database. For cross-region use db_instance_arn
  replicate_source_db    = module.master.db_instance_id
  create_random_password = false

  engine               = local.engine
  engine_version       = local.engine_version
  family               = local.family
  major_engine_version = local.major_engine_version
  instance_class       = local.instance_class

  allocated_storage     = local.allocated_storage
  max_allocated_storage = local.max_allocated_storage

  port = local.port

  multi_az               = false
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Tue:00:00-Tue:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  # TODO this should be true for prod
  deletion_protection     = false
  storage_encrypted       = true

  tags = local.tags
}


