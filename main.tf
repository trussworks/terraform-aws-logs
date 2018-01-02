/**
 * Creates and configures an S3 bucket for storing logs from various AWS
 * services and enables CloudTrail on all regions. Logs will expire after a
 * default of 90 days.
 *
 * Logging from the following services is supported:
 *
 * * [CloudTrail](https://aws.amazon.com/cloudtrail/)
 * * [Config](https://aws.amazon.com/config/)
 * * [ELB](https://aws.amazon.com/elasticloadbalancing/)
 * * [RedShift](https://aws.amazon.com/redshift/)
 *
 * ## Usage
 *
 *     module "aws_logs" {
 *       source         = "trussworks/aws/logs"
 *       s3_bucket_name = "my-company-aws-logs"
 *       region         = "us-west-2"
 *       expiration     = 90
 *     }
 */

// Get the account id of the AWS ELB service account in a given region for the
// purpose of whitelisting in a S3 bucket policy.
data "aws_elb_service_account" "main" {}

// Get the account id of the RedShift service account in a given region for the
// purpose of allowing RedShift to store audit data in S3.
data "aws_redshift_service_account" "main" {}

// JSON template defining all the access controls to allow AWS services to write
// to this bucket
data "template_file" "aws_logs_policy" {
  template = "${file("${path.module}/policy.tpl")}"

  vars = {
    bucket                  = "${var.s3_bucket_name}"
    cloudtrail_logs_prefix  = "${var.cloudtrail_logs_prefix}"
    config_logs_prefix      = "${var.config_logs_prefix}"
    elb_log_account_arn     = "${data.aws_elb_service_account.main.arn}"
    elb_logs_prefix         = "${var.elb_logs_prefix}"
    redshift_log_account_id = "${data.aws_redshift_service_account.main.id}"
    redshift_logs_prefix    = "${var.redshift_logs_prefix}"
  }
}

resource "aws_s3_bucket" "aws_logs" {
  bucket = "${var.s3_bucket_name}"
  region = "${var.region}"
  policy = "${data.template_file.aws_logs_policy.rendered}"

  lifecycle_rule {
    id      = "expire_all_logs"
    prefix  = "/*"
    enabled = true

    expiration {
      days = "${var.expiration}"
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

resource "aws_cloudtrail" "cloudtrail" {
  name           = "cloudtrail"
  s3_key_prefix  = "cloudtrail"
  s3_bucket_name = "${var.s3_bucket_name}"

  // use a single s3 bucket for all aws regions
  is_multi_region_trail = true

  // enable log file validation to detect tampering
  enable_log_file_validation = true
  depends_on                 = ["aws_s3_bucket.aws_logs"]
}
