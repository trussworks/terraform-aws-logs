/**
 * Supports two main uses cases:
 *
 * 1. Creates and configures a single private S3 bucket for storing logs from various AWS services, which are nested as bucket prefixes. Logs will expire after a default of 90 days, with option to configure retention value.
 * 1. Creates and configures a single private S3 bucket for a single AWS service. Logs will expire after a default of 90 days, with option to configure retention value.
 *
 * Logging from the following services is supported for both cases:
 *
 * * [CloudTrail](https://aws.amazon.com/cloudtrail/)
 * * [Config](https://aws.amazon.com/config/)
 * * [Classic Load Balancer (ELB) and Application Load Balancer (ALB)](https://aws.amazon.com/elasticloadbalancing/)
 * * [RedShift](https://aws.amazon.com/redshift/)
 * * [S3](https://aws.amazon.com/s3/)
 *
 * ## Usage for a single log bucket storing logs from multiple services
 *
 *     # Allows all services to log to bucket
 *     module "aws_logs" {
 *       source         = "trussworks/logs/aws"
 *       s3_bucket_name = "my-company-aws-logs"
 *       region         = "us-west-2"
 *     }
 *
 * ## Usage for a single log bucket storing logs from a single service
 *
 *     #  Allows only the service specified (elb in this case) to log to the bucket
 *     module "aws_logs" {
 *       source         = "trussworks/logs/aws"
 *       s3_bucket_name = "my-company-aws-logs-elb"
 *       region         = "us-west-2"
 *       default_allow = false
 *       allow_elb     = true
 *     }
 */

# Get the account id of the AWS ELB service account in a given region for the
# purpose of whitelisting in a S3 bucket policy.
data "aws_elb_service_account" "main" {}

# Get the account id of the RedShift service account in a given region for the
# purpose of allowing RedShift to store audit data in S3.
data "aws_redshift_service_account" "main" {}

# The AWS region currently being used.
data "aws_region" "current" {}

# The AWS account id
data "aws_caller_identity" "current" {}

# JSON template defining all the access controls to allow AWS services to write
# to this bucket
data "template_file" "aws_logs_policy" {
  template = "${file("${path.module}/policy.tpl")}"

  vars = {
    region                  = "${var.region}"
    bucket                  = "${var.s3_bucket_name}"
    default_allow           = "${var.default_allow}"
    allow_cloudtrail        = "${var.allow_cloudtrail}"
    cloudtrail_logs_prefix  = "${var.cloudtrail_logs_prefix}"
    allow_cloudwatch        = "${var.allow_cloudwatch}"
    cloudwatch_logs_prefix  = "${var.cloudwatch_logs_prefix}"
    allow_config            = "${var.allow_config}"
    config_logs_prefix      = "${var.config_logs_prefix}"
    allow_elb               = "${var.allow_elb}"
    elb_log_account_arn     = "${data.aws_elb_service_account.main.arn}"
    elb_logs_prefix         = "${var.elb_logs_prefix}"
    allow_alb               = "${var.allow_alb}"
    alb_logs_prefix         = "${var.alb_logs_prefix}"
    allow_redshift          = "${var.allow_redshift}"
    redshift_log_account_id = "${data.aws_redshift_service_account.main.id}"
    redshift_logs_prefix    = "${var.redshift_logs_prefix}"
  }
}

#
# S3 Bucket
#

resource "aws_s3_bucket" "aws_logs" {
  bucket = "${var.s3_bucket_name}"

  acl    = "${var.default_allow || var.allow_s3  ? "log-delivery-write" : "private"}"
  region = "${var.region}"

  lifecycle_rule {
    id      = "expire_all_logs"
    prefix  = "/*"
    enabled = true

    expiration {
      days = "${var.s3_log_bucket_retention}"
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags {
    Name = "${var.s3_bucket_name}"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = "${aws_s3_bucket.aws_logs.id}"
  count  = "${var.default_allow || !var.allow_s3 ? 1 : 0}"

  policy = "${data.template_file.aws_logs_policy.rendered}"
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = "${aws_s3_bucket.aws_logs.id}"

  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}
