
variable "aws_region" {
  description = "aws region name"
  type        = string
  default     = "eu-north-1"
}

variable "db_password" {
  description = "db_password"
  type        = string
  default     = "admindev"
}
variable "db_user" {
  description = "db_user"
  type        = string
  default     = "admindev"
}
variable "environment" {
  description = "environment"
  type        = string
  default     = ""
}
variable "vpc_cidr_block" {
  description = "environment"
  type        = string
  default     = ""
}
variable "vpc_private_subnets" {
  description = "private subnets"
  type        = list(string)
  default     = [""]
}

variable "vpc_public_subnets" {
  description = "public subnets"
  type        = list(string)
  default     = [""]
}

variable "avail_zones" {
  description = "public subnets"
  type        = list(string)
  default     = [""]
}

variable "vpc_database_subnets" {
  description = "Database subnets"
  type        = list(string)
  default     = [""]
}

variable "log_destination_arn" {
  description = "ARN of S3 bucket to receive AWS service logs"
  type        = string
  default     = ""
}

variable "service_name" {
  description = "Parent service name"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to be added to all resources"
  type        = map(string)
  default     = {}
}

