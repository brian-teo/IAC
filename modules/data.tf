

data "aws_caller_identity" "current" {}

data "aws_acm_certificate" "issued" {
  domain   = "*.teoricentralen.dev"
  statuses = ["ISSUED"]
}
