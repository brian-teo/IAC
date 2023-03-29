# Setup and Enable VPC logging

### Add S3 bucket
resource "aws_flow_log" "s3bucket" {
  log_destination      = aws_s3_bucket.vpc_flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = module.vpc.vpc_id
}

resource "aws_s3_bucket" "vpc_flow_logs" {
  bucket_prefix = "${module.vpc.name}-flow-log-a"
  acl           = "private"
  force_destroy = true
  versioning {
    enabled = true
  }
  lifecycle_rule {
    id      = "quarterly_retention"
    prefix  = ""
    enabled = true
    expiration {
      days = 92
    }
    noncurrent_version_expiration {
      days = 92
    }
    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }
    noncurrent_version_transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }
    abort_incomplete_multipart_upload_days = 1
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = local.tags

}

resource "aws_s3_bucket_public_access_block" "vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_policy" "vpc_flow_logs" {
  depends_on = [aws_flow_log.s3bucket]
  bucket     = aws_s3_bucket.vpc_flow_logs.id
  policy     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Sid": "AllowSSLRequestsOnly",
            "Action": "s3:*",
            "Effect": "Deny",
            "Resource": [
                "${aws_s3_bucket.vpc_flow_logs.arn}",
                "${aws_s3_bucket.vpc_flow_logs.arn}/*"
            ],
            "Condition": {
                "Bool": {
                     "aws:SecureTransport": "false"
                }
            },
           "Principal": "*"
        },
	{
      "Sid": "AWSLogDeliveryAclCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.vpc_flow_logs.arn}"
    },
    {
      "Sid": "AWSLogDeliveryWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.vpc_flow_logs.arn}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }

    ]
}
EOF

}
