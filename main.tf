/**
 * Creates and configures an S3 bucket for storing logs from various AWS
 * services and enables CloudTrail on all regions. Logs will expire after a
 * default of 90 days. Includes support for sending CloudTrail events to a
 * CloudWatch Logs group.
 *
 * Logging from the following services is supported:
 *
 * * [CloudTrail](https://aws.amazon.com/cloudtrail/)
 * * [Config](https://aws.amazon.com/config/)
 * * [Elastic Load Balancing](https://aws.amazon.com/elasticloadbalancing/)
 * * [RedShift](https://aws.amazon.com/redshift/)
 * * [S3](https://aws.amazon.com/s3/)
 *
 * ## Usage
 *
 *     module "aws_logs" {
 *       source         = "trussworks/logs/aws"
 *       s3_bucket_name = "my-company-aws-logs"
 *       region         = "us-west-2"
 *       s3_log_bucket_retention     = 90
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
    cloudwatch_logs_prefix  = "${var.cloudwatch_logs_prefix}"
    cloudtrail_logs_prefix  = "${var.cloudtrail_logs_prefix}"
    config_logs_prefix      = "${var.config_logs_prefix}"
    elb_log_account_arn     = "${data.aws_elb_service_account.main.arn}"
    elb_logs_prefix         = "${var.elb_logs_prefix}"
    alb_logs_prefix         = "${var.alb_logs_prefix}"
    redshift_log_account_id = "${data.aws_redshift_service_account.main.id}"
    redshift_logs_prefix    = "${var.redshift_logs_prefix}"
  }
}

#
# S3 Bucket
#

resource "aws_s3_bucket" "aws_logs" {
  bucket = "${var.s3_bucket_name}"

  acl    = "log-delivery-write"
  region = "${var.region}"
  policy = "${data.template_file.aws_logs_policy.rendered}"

  lifecycle_rule {
    id      = "expire_all_logs"
    prefix  = "/*"
    enabled = true

    s3_log_bucket_retention {
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

#
# IAM
#

data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_logs" {
  statement {
    sid = "WriteCloudWatchLogs"

    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.cloudtrail_cloudwatch_logs_group}:*"]
  }
}

resource "aws_iam_role" "main" {
  count              = "${var.enable_cloudtrail ? 1 : 0}"
  name               = "cloudtrail-cloudwatch-logs-role"
  assume_role_policy = "${data.aws_iam_policy_document.cloudtrail_assume_role.json}"
}

resource "aws_iam_policy" "main" {
  count  = "${var.enable_cloudtrail ? 1 : 0}"
  name   = "cloudtrail-cloudwatch-logs-policy"
  policy = "${data.aws_iam_policy_document.cloudtrail_cloudwatch_logs.json}"
}

resource "aws_iam_policy_attachment" "main" {
  count      = "${var.enable_cloudtrail ? 1 : 0}"
  name       = "cloudtrail-cloudwatch-logs-policy-attachment"
  policy_arn = "${aws_iam_policy.main.arn}"
  roles      = ["${aws_iam_role.main.name}"]
}

#
# CloudWatch Logs
#

resource "aws_cloudwatch_log_group" "main" {
  count             = "${var.enable_cloudtrail ? 1 : 0}"
  name              = "${var.cloudtrail_cloudwatch_logs_group}"
  retention_in_days = "${var.cloudwatch_log_group_retention}"
}

#
# CloudTrail
#

resource "aws_cloudtrail" "cloudtrail" {
  depends_on = [
    "aws_cloudwatch_log_group.main",
    "aws_s3_bucket.aws_logs",
  ]

  count = "${var.enable_cloudtrail ? 1 : 0}"

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.main.arn}"
  cloud_watch_logs_role_arn  = "${aws_iam_role.main.arn}"

  name           = "cloudtrail"
  s3_key_prefix  = "cloudtrail"
  s3_bucket_name = "${var.s3_bucket_name}"

  # use a single s3 bucket for all aws regions
  is_multi_region_trail = true

  # enable log file validation to detect tampering
  enable_log_file_validation = true
}
